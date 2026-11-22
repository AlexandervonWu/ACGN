import Std

namespace ACGN.Eleventh.P404

structure Face where
  classId : Nat
  resultType : Nat
  context : List (Nat × Nat)

abbrev Slot (a : Face) := {s : Nat × Nat // s ∈ a.context}
abbrev MapTo (p c : Face) := Slot p → Slot c

/-- Values of a map are already members of its exact declared codomain. -/
def Typed {p c : Face} (f : MapTo p c) : Prop :=
  (∀ x y, f x = f y → x = y) ∧ ∀ x, (f x).val.2 = x.val.2

theorem typed_identity (c : Face) : Typed (id : MapTo c c) :=
  ⟨fun _ _ h => h, fun _ => rfl⟩

theorem typed_composition {a b c : Face} {f : MapTo b a} {g : MapTo c b}
    (hf : Typed f) (hg : Typed g) : Typed (fun s => f (g s)) :=
  ⟨fun x y h => hg.1 x y (hf.1 _ _ h), fun x => (hf.2 _).trans (hg.2 x)⟩

/-- Identity, output type, context and the entire slot map contribute to an endpoint. -/
structure Endpoint (ambient : Face) where
  subject : Face
  map : MapTo subject ambient

def witness (c : Face) : Endpoint c := ⟨c, id⟩
def invoke (p : Face) {c : Face} (f : MapTo p c) : Endpoint c := ⟨p, f⟩
def transport {a b : Face} (x : Endpoint a) (f : MapTo a b) : Endpoint b :=
  ⟨x.subject, fun s => f (x.map s)⟩

abbrev Seeds := (c : Face) → Endpoint c → Endpoint c → Prop

/-- Seeds are the independently accepted, permitted equality premises. Their truth is
    separate from the graph's duty to install the correct *directed* endpoints. -/
inductive Derives (seed : Seeds) : {c : Face} → Endpoint c → Endpoint c → Prop where
  | premise {c l r} : seed c l r → Derives seed l r
  | refl {c} (x : Endpoint c) : Derives seed x x
  | symm {c} {l r : Endpoint c} : Derives seed l r → Derives seed r l
  | trans {c} {l m r : Endpoint c} : Derives seed l m → Derives seed m r → Derives seed l r
  | rename {a b} {l r : Endpoint a} (f : MapTo a b) : Typed f →
      Derives seed l r → Derives seed (transport l f) (transport r f)

/-- The caller's original proof may have the reverse orientation. The two success
    arms of EqualityCertificates.orient compare complete endpoints. -/
structure Admission (seed : Seeds) (c p : Face) (f : MapTo p c) where
  embedding : Typed f
  sort : c.resultType = p.resultType
  left : Endpoint c
  right : Endpoint c
  checked : Derives seed left right
  alignment : (left = witness c ∧ right = invoke p f) ∨
            (right = witness c ∧ left = invoke p f)

def Exact (seed : Seeds) (c p : Face) (f : MapTo p c) : Prop :=
  Typed f ∧ c.resultType = p.resultType ∧ Derives seed (witness c) (invoke p f)

theorem orient_exact {s c p f} (a : Admission s c p f) : Exact s c p f := by
  refine ⟨a.embedding, a.sort, ?_⟩
  rcases a.alignment with ⟨hl, hr⟩ | ⟨hr, hl⟩
  · simpa only [← hl, ← hr] using a.checked
  · simpa only [← hl, ← hr] using a.checked.symm

theorem identity_exact (s : Seeds) (a : Face) : Exact s a a id :=
  ⟨typed_identity a, rfl, .refl (witness a)⟩

theorem concatenate_exact {s a b c} {f : MapTo b a} {g : MapTo c b}
    (ab : Exact s a b f) (bc : Exact s b c g) : Exact s a c (fun x => f (g x)) :=
  ⟨typed_composition ab.1 bc.1, ab.2.1.trans bc.2.1,
    .trans ab.2.2 (.rename f ab.1 bc.2.2)⟩

/-- Parent paths carry primitive oriented admissions. Compression retains those
    primitives and combines embeddings in parent-to-child order. -/
inductive Path (s : Seeds) : (a b : Face) → MapTo b a → Prop where
  | id {a} : Path s a a id
  | step {a b c} {f : MapTo b a} {g : MapTo c b} (edge : Admission s a b f)
      (rest : Path s b c g) : Path s a c (fun x => f (g x))

theorem path_exact {s a b f} (q : Path s a b f) : Exact s a b f := by
  induction q with
  | id => exact identity_exact _ _
  | step e _ ih => exact concatenate_exact (orient_exact e) ih

theorem historical_find_exact {s c leader ambient} {f : MapTo leader c} {g : MapTo c ambient}
    (q : Path s c leader f) (hg : Typed g) {start : Endpoint ambient}
    (normalization : Derives s start (invoke c g)) :
    Derives s start (invoke leader (fun x => g (f x))) :=
  .trans normalization (.rename g hg (path_exact q).2.2)

inductive Mode | required | testOnly | structural deriving DecidableEq
inductive Route | root | certifiedLink | structuralLink | compression | restrictedChild deriving DecidableEq

structure Assignment where
  child : Face
  parent : Face
  mapping : MapTo parent child

/-- Each constructor records the inputs to its actual write. A restriction derives
    the new edge from the old path and the independently supplied factorization. -/
inductive Write (s : Seeds) : Mode → Route → Assignment → Prop where
  | root (m) (a : Face) : Write s m .root ⟨a,a,id⟩
  | link (m) {c p f} (e : Admission s c p f) : Write s m .certifiedLink ⟨c,p,f⟩
  | fixture {c p f} : Typed f → c.resultType = p.resultType →
      Write s .structural .structuralLink ⟨c,p,f⟩
  | fixtureCompress {c p f} : Typed f → c.resultType = p.resultType →
      Write s .structural .compression ⟨c,p,f⟩
  | compress (m) {c p f} (path : Path s c p f) : Write s m .compression ⟨c,p,f⟩
  | restrict (m) {c old new} {f : MapTo old c} {inc : MapTo new old}
      (oldPath : Path s c old f) (factor : Admission s old new inc) :
      Write s m .restrictedChild ⟨c,new,fun x => f (inc x)⟩

theorem certification_excludes_structural_write {s m a} (h : Write s m .structuralLink a)
    (hm : m ≠ .structural) : False := by cases h; exact hm rfl

theorem every_certifying_write_exact {s m k a} (h : Write s m k a) (hm : m ≠ .structural) :
    Exact s a.child a.parent a.mapping := by
  cases h with
  | root => exact identity_exact _ _
  | link _ e => exact orient_exact e
  | fixture => exact False.elim (hm rfl)
  | fixtureCompress => exact False.elim (hm rfl)
  | compress _ p => exact path_exact p
  | @restrict _ c old new f inc p q =>
      exact @concatenate_exact s c old new f inc (path_exact p) (orient_exact q)

/-- List form of last-write-wins keyed storage, including each entry of a
    private restriction replacement map committed by putAll. -/
inductive History (s : Seeds) (m : Mode) : List (Nat × Assignment) → Prop where
  | empty : History s m []
  | put {a k tail} (h : Write s m k a) (past : History s m tail) :
      History s m ((a.child.classId,a) :: tail)

theorem installed_parent_has_exact_certificate {s m xs key a} (h : History s m xs)
    (hm : m ≠ .structural) (member : (key,a) ∈ xs) :
    key = a.child.classId ∧ Typed a.mapping ∧ a.child.resultType = a.parent.resultType ∧
    Derives s (witness a.child) (invoke a.parent a.mapping) := by
  induction h with
  | empty => simp at member
  | put w _ ih =>
    rcases List.mem_cons.mp member with ha | ht
    · cases ha; exact ⟨rfl, every_certifying_write_exact w hm⟩
    · exact ih ht

/-- Each indirect putAll only publishes entries of the replacement map. -/
theorem replacement_commit_preserves_history {s m staged installed}
    (hs : History s m staged) (hi : History s m installed) : History s m (staged ++ installed) := by
  induction hs with
  | empty => exact hi
  | put w _ ih => exact .put w ih

inductive Instruction | direct | compressed | fresh | commit | restrictedChild | restrictedRoot
  deriving DecidableEq, Repr

def writeSites : List (String × Instruction) := [
  ("linkRoots\tassignments.put(step.child().id(),ParentAssignment.direct(step))", .direct),
  ("pathToRoot\tassignments.put(id,ParentAssignment.compressed(full))", .compressed),
  ("register\tassignments.put(eclass.id(),ParentAssignment.root(eclass))", .fresh),
  ("restrictLeader\tassignments.putAll(replacements)", .commit),
  ("restrictLeader\treplacements.put(child.id(),ParentAssignment.direct(ParentStep.certified(edge)))", .restrictedChild),
  ("restrictLeader\treplacements.put(original.id(),ParentAssignment.root(replacement))", .restrictedRoot)]

def decode (lines : List String) : Option (List Instruction) :=
  match lines.mapM (fun line => (writeSites.lookup line)) with
  | none => none
  | some commands => if commands = writeSites.map Prod.snd then some commands else none

theorem decoded_program_is_complete {lines ops} (h : decode lines = some ops) :
    ops = writeSites.map Prod.snd := by
  unfold decode at h
  split at h
  · contradiction
  · rename_i commands hmap
    change (if commands = writeSites.map Prod.snd then some commands else none) = some ops at h
    split at h <;> simp_all

/-- This semantics uses the arguments at the observed write site. Normal inputs
    have verified equality derivations, while raw setup inputs remain distinguishable. -/
inductive Operands (s : Seeds) where
  | root (a : Face)
  | certified {c p f} (proof : Admission s c p f)
  | raw {c p : Face} {f : MapTo p c} (typed : Typed f) (sort : c.resultType = p.resultType)
  | path {c p f} (chain : Path s c p f)
  | rawPath {c p : Face} {f : MapTo p c} (typed : Typed f) (sort : c.resultType = p.resultType)
  | replacement {c old new} {f : MapTo old c} {inc : MapTo new old}
      (path : Path s c old f) (factor : Admission s old new inc)

/-- PutAll is a separate atomic transfer proved below. -/
def prepare {s} (m : Mode) : Instruction → Operands s → Option Assignment
  | .fresh, .root a | .restrictedRoot, .root a => some ⟨a,a,id⟩
  | .direct, @Operands.certified _ c p f _ => some ⟨c,p,f⟩
  | .direct, @Operands.raw _ c p f _ _ => if m = .structural then some ⟨c,p,f⟩ else none
  | .compressed, @Operands.path _ c p f _ => some ⟨c,p,f⟩
  | .compressed, @Operands.rawPath _ c p f _ _ => if m = .structural then some ⟨c,p,f⟩ else none
  | .restrictedChild, @Operands.replacement _ c _ new f inc _ _ => some ⟨c,new,fun x => f (inc x)⟩
  | _, _ => none

theorem prepared_writes_have_derivations {s m op input a}
    (h : @prepare s m op input = some a) : ∃ k, Write s m k a := by
  cases op <;> cases input <;> simp [prepare] at h
  all_goals try
    (subst a; first | exact ⟨_, .root _ _⟩ | exact ⟨_, .link _ ‹_›⟩ |
        exact ⟨_, .compress _ ‹_›⟩ | exact ⟨_, .restrict _ ‹_› ‹_›⟩)
  case direct.raw =>
    obtain ⟨rfl,rfl⟩ := h
    exact ⟨_, .fixture ‹_› ‹_›⟩
  case compressed.rawPath =>
    obtain ⟨rfl,rfl⟩ := h
    exact ⟨_, .fixtureCompress ‹_› ‹_›⟩

structure State where
  installed : List (Nat × Assignment)
  staged : List (Nat × Assignment)

/-- A trace supplies the actual store kind. The two restricted puts write into
    the fresh local map, and putAll publishes those exact entries. -/
inductive Execution (s : Seeds) (m : Mode) (program : List Instruction) : State → Prop where
  | initial : Execution s m program ⟨[],[]⟩
  | store {old : State} {op : Instruction} {args : Operands s} {a : Assignment} (prior : Execution s m program old) (present : op ∈ program)
      (admitted : prepare m op args = some a) :
      Execution s m program (if op = .restrictedChild ∨ op = .restrictedRoot
        then ⟨old.installed,(a.child.classId,a)::old.staged⟩
        else ⟨(a.child.classId,a)::old.installed,old.staged⟩)
  | commit {old} : Execution s m program old → Instruction.commit ∈ program →
      Execution s m program ⟨old.staged ++ old.installed,[]⟩
  | freshStaging {old} : Execution s m program old → Execution s m program ⟨old.installed,[]⟩

theorem execution_preserves_both_stores {s m p st} (e : Execution s m p st) :
    History s m st.installed ∧ History s m st.staged := by
  induction e with
  | initial => exact ⟨.empty,.empty⟩
  | store _ _ h ih =>
    obtain ⟨_, hw⟩ := prepared_writes_have_derivations h
    split
    · exact ⟨ih.1,.put hw ih.2⟩
    · exact ⟨.put hw ih.1,ih.2⟩
  | commit _ _ ih => exact ⟨replacement_commit_preserves_history ih.2 ih.1,.empty⟩
  | freshStaging _ ih => exact ⟨ih.1,.empty⟩

theorem decoded_installation_exact {lines ops s m st key a}
    (compiled : decode lines = some ops) (run : Execution s m ops st) (hm : m ≠ .structural)
    (installed : (key,a) ∈ st.installed) :
    ops = writeSites.map Prod.snd ∧ key = a.child.classId ∧ Typed a.mapping ∧
    a.child.resultType = a.parent.resultType ∧ Derives s (witness a.child) (invoke a.parent a.mapping) :=
  ⟨decoded_program_is_complete compiled, installed_parent_has_exact_certificate
    (execution_preserves_both_stores run).1 hm installed⟩

end ACGN.Eleventh.P404
#print axioms ACGN.Eleventh.P404.typed_identity
#print axioms ACGN.Eleventh.P404.typed_composition
#print axioms ACGN.Eleventh.P404.orient_exact
#print axioms ACGN.Eleventh.P404.identity_exact
#print axioms ACGN.Eleventh.P404.concatenate_exact
#print axioms ACGN.Eleventh.P404.path_exact
#print axioms ACGN.Eleventh.P404.historical_find_exact
#print axioms ACGN.Eleventh.P404.certification_excludes_structural_write
#print axioms ACGN.Eleventh.P404.every_certifying_write_exact
#print axioms ACGN.Eleventh.P404.installed_parent_has_exact_certificate
#print axioms ACGN.Eleventh.P404.replacement_commit_preserves_history
#print axioms ACGN.Eleventh.P404.decoded_program_is_complete
#print axioms ACGN.Eleventh.P404.prepared_writes_have_derivations
#print axioms ACGN.Eleventh.P404.execution_preserves_both_stores
#print axioms ACGN.Eleventh.P404.decoded_installation_exact
