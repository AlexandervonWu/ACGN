import Std

namespace A226

/-- The parser image records correlated products and proof-only live module ownership. -/
structure Column where
  atom : Nat
  directParents : List Nat
  moduleOwner : Option Nat
  deriving DecidableEq

structure Dag where
  /-- Java rejects zero arity when constructing a dependent DAG. -/
  widthPred : Nat
  alternatives : List (List Column)
  commonAncestor : Option Nat
  deriving DecidableEq

def width (d : Dag) := d.widthPred + 1
def emptyOf (d : Dag) : Dag := ⟨d.widthPred, [], none⟩

inductive Op | plus | intersect deriving DecidableEq
inductive Issue | unsupported | cycle | disagreement deriving DecidableEq
inductive Node
  | atom (parser : Option Dag)
  | operation (op : Op) (parser : Option Dag) (children : List Nat)

structure Check where
  occurrence : Nat
  operation : Op
  parser : Dag
  derived : Dag

structure Return where
  dag : Dag
  checks : List Check

abbrev Outcome (α : Type) := Except Issue α

def consistent (ws : List Check) : Prop := ∀ w ∈ ws, w.derived = w.parser

def select (combine : Op → List Dag → Outcome Dag) (op : Op) : List Dag → Outcome Dag
  | [] => .error .unsupported
  | [d] => .ok d
  | a :: b :: tail => combine op (a :: b :: tail)

def finish (idx : Nat) (op : Op) (parser : Dag) (children : List Return)
    (combine : Op → List Dag → Outcome Dag) : Outcome Return :=
  match select combine op (children.map Return.dag) with
  | .error e => .error e
  | .ok d =>
    if d = parser then .ok ⟨d, ⟨idx,op,parser,d⟩ :: children.flatMap Return.checks⟩
    else .error .disagreement

def collect (visit : Nat → Outcome Return) : List Nat → Outcome (List Return)
  | [] => .ok []
  | k::ks =>
    match visit k with
    | .error e => .error e
    | .ok head =>
      match collect visit ks with
      | .error e => .error e
      | .ok tail => .ok (head::tail)

structure SourceGraph where
  lookup : Nat → Node
  primitiveInt : Nat → Bool

instance : CoeFun SourceGraph (fun _ => Nat → Node) := ⟨SourceGraph.lookup⟩

def eligible (source : SourceGraph) (parent child : Nat) (visit : Nat → Outcome Return) : Outcome Return :=
  if source.primitiveInt parent = source.primitiveInt child then visit child else .error .unsupported

theorem eligible_success (g : SourceGraph) (p j : Nat) (visit : Nat → Outcome Return) {v}
    (ok : eligible g p j visit = .ok v) :
    g.primitiveInt p = g.primitiveInt j ∧ visit j = .ok v := by
  by_cases h : g.primitiveInt p = g.primitiveInt j
  · exact ⟨h, by simpa [eligible,h] using ok⟩
  · simp [eligible,h] at ok

theorem mixed_representation_refused (g : SourceGraph) (p j : Nat) (visit : Nat → Outcome Return)
    (different : g.primitiveInt p ≠ g.primitiveInt j) :
    eligible g p j visit = .error .unsupported := by simp [eligible,different]

/-- Fuel bounds a finite unfolding of the source graph. Exhaustion is outside its qualified slice. -/
def walk (source : SourceGraph) (combine : Op → List Dag → Outcome Dag) :
    Nat → List Nat → Nat → Outcome Return
  | 0, _, _ => .error .unsupported
  | fuel+1, active, i =>
    match source i with
    | .atom none | .operation _ none _ => .error .unsupported
    | .atom (some p) => .ok ⟨p,[]⟩
    | .operation op (some p) ns =>
      if i ∈ active then .error .cycle else
      match collect (fun j => eligible source i j (walk source combine fuel (i::active))) ns with
      | .error e => .error e
      | .ok xs => finish i op p xs combine

theorem collected_from_source (f : Nat → Outcome Return) (ids : List Nat)
    {xs} (h : collect f ids = .ok xs) :
    xs.length = ids.length ∧ ∀ x ∈ xs, ∃ i ∈ ids, f i = .ok x := by
  induction ids generalizing xs with
  | nil => simp [collect] at h; subst xs; simp
  | cons id ids ih =>
    cases head : f id with
    | error e => simp [collect,head] at h
    | ok x =>
      cases tail : collect f ids with
      | error e => simp [collect,head,tail] at h
      | ok ys =>
        simp [collect,head,tail] at h
        subst xs
        obtain ⟨len,origin⟩ := ih tail
        refine ⟨by simp [len],?_⟩
        intro v hv
        rcases List.mem_cons.mp hv with eq | mem
        · exact ⟨id,by simp,eq ▸ head⟩
        · obtain ⟨i,hi,hv⟩ := origin v mem
          exact ⟨i,List.mem_cons_of_mem _ hi,hv⟩

theorem finish_checks_every_child (combine : Op → List Dag → Outcome Dag)
    (i : Nat) (op : Op) (p : Dag) (xs : List Return) {v}
    (good : ∀ x ∈ xs, consistent x.checks)
    (ok : finish i op p xs combine = .ok v) :
    v.dag = p ∧ consistent v.checks ∧
      select combine op (xs.map Return.dag) = .ok v.dag := by
  cases d : select combine op (xs.map Return.dag) with
  | error e => simp [finish,d] at ok
  | ok result =>
    by_cases eq : result=p
    · simp [finish,d,eq] at ok
      subst v
      refine ⟨rfl,?_,by simp [eq]⟩
      intro w hw
      rcases List.mem_cons.mp hw with hd | tl
      · subst w; rfl
      · obtain ⟨x,hx,hw⟩ := List.mem_flatMap.mp tl
        exact good x hx w hw
    · simp [finish,d,eq] at ok

theorem recursive_parser_agreement (source : SourceGraph) (combine : Op → List Dag → Outcome Dag)
    (fuel : Nat) (active : List Nat) (i : Nat) {v}
    (ok : walk source combine fuel active i = .ok v) :
    consistent v.checks ∧
      (match source i with | .atom parser | .operation _ parser _ => parser) = some v.dag := by
  induction fuel generalizing active i v with
  | zero => simp [walk] at ok
  | succ fuel ih =>
    cases hn : source i with
    | atom p =>
      cases p with
      | none => simp [walk,hn] at ok
      | some p => simp [walk,hn] at ok; subst v; simp [consistent]
    | operation op p ns =>
      cases p with
      | none => simp [walk,hn] at ok
      | some p =>
        by_cases cyclic : i ∈ active
        · simp [walk,hn,cyclic] at ok
        · cases children : collect (fun j => eligible source i j (walk source combine fuel (i::active))) ns with
          | error e => simp [walk,hn,cyclic,children] at ok
          | ok xs =>
            have finished : finish i op p xs combine = .ok v := by simpa [walk,hn,cyclic,children] using ok
            have good : ∀ x ∈ xs, consistent x.checks := by
              intro x hx
              obtain ⟨j,_,step⟩ := (collected_from_source _ _ children).2 x hx
              exact (ih _ _ (eligible_success source i j _ step).2).1
            obtain ⟨eq,agree,_⟩ := finish_checks_every_child combine i op p xs good finished
            exact ⟨agree,by simp [eq]⟩

theorem collected_at_each_index (f : Nat → Outcome Return) (ids : List Nat) {xs}
    (ok : collect f ids = .ok xs) (k j : Nat) (position : ids[k]? = some j) :
    ∃ v, xs[k]? = some v ∧ f j = .ok v := by
  induction ids generalizing xs k with
  | nil => simp at position
  | cons h t ih =>
    cases fh : f h with
    | error e => simp [collect,fh] at ok
    | ok first =>
      cases ft : collect f t with
      | error e => simp [collect,fh,ft] at ok
      | ok rest =>
        simp [collect,fh,ft] at ok
        subst xs
        cases k with
        | zero => simp at position; subst j; exact ⟨first,rfl,fh⟩
        | succ k => exact ih ft k (by simpa using position)

/-- Every actual child position of an accepted set occurrence has its own successful
recursive derivation, and exactly that child's descendant checks occur in the parent. -/
theorem every_accepted_set_child (source : SourceGraph) (combine : Op → List Dag → Outcome Dag)
    {fuel active i op p ids parent} {k j : Nat}
    (atSet : source i = .operation op (some p) ids)
    (ok : walk source combine (fuel+1) active i = .ok parent) (child : ids[k]? = some j) :
    ∃ v, walk source combine fuel (i::active) j = .ok v ∧
      ∀ w ∈ v.checks, w ∈ parent.checks := by
  by_cases cycle : i ∈ active
  · simp [walk,atSet,cycle] at ok
  · cases step : collect (fun j => eligible source i j (walk source combine fuel (i::active))) ids with
    | error e => simp [walk,atSet,cycle,step] at ok
    | ok returns =>
      obtain ⟨v,hv,computed⟩ := collected_at_each_index _ _ step k j child
      refine ⟨v,(eligible_success source i j _ computed).2,?_⟩
      have finished : finish i op p returns combine = .ok parent := by simpa [walk,atSet,cycle,step] using ok
      cases d : select combine op (returns.map Return.dag) with
      | error e => simp [finish,d] at finished
      | ok result =>
        by_cases eq : result=p
        · simp [finish,d,eq] at finished
          subst parent
          intro w hw
          have member : v ∈ returns := List.mem_of_getElem? hv
          exact List.mem_cons_of_mem _ (List.mem_flatMap.mpr ⟨v,member,hw⟩)
        · simp [finish,d,eq] at finished

theorem matched_empty_keeps_parser_arity (source : SourceGraph) (combine : Op → List Dag → Outcome Dag)
    {fuel active i op p ids v}
    (atSet : source i = .operation op (some p) ids)
    (ok : walk source combine fuel active i = .ok v) (empty : v.dag.alternatives = []) :
    p.alternatives = [] ∧ width p = width v.dag ∧ 0 < width p := by
  have eq := (recursive_parser_agreement source combine fuel active i ok).2
  simp [atSet] at eq
  subst p
  exact ⟨empty,rfl,by simp [width]⟩

theorem genuine_disagreement_blocks (i : Nat) (op : Op) (p observed : Dag) (xs : List Return)
    (combine : Op → List Dag → Outcome Dag)
    (found : select combine op (xs.map Return.dag) = .ok observed) (different : observed ≠ p) :
    finish i op p xs combine = .error .disagreement := by simp [finish,found,different]

theorem recursive_occurrence_blocks (source : SourceGraph) (combine : Op → List Dag → Outcome Dag)
    {i fuel op p ns active} (node : source i = .operation op (some p) ns) (cycle : i ∈ active) :
    walk source combine (fuel+1) active i = .error .cycle := by simp [walk,node,cycle]

theorem typed_empty_keeps_width (d : Dag) :
    (emptyOf d).alternatives = [] ∧ width (emptyOf d) = width d ∧ 0 < width (emptyOf d) := by
  simp [emptyOf,width]

inductive Authority | dependent | guarded | fixed | rejected deriving DecidableEq

/-- An unsupported dependent step may be served by a separately proved guarded JOIN.
Only absence of both derivations enters the fixed-binary route. -/
def route (result : Outcome α) (guarded : Bool) : Authority :=
  match result with
  | .ok _ => .dependent
  | .error .unsupported => if guarded then .guarded else .fixed
  | .error .cycle | .error .disagreement => .rejected

theorem fixed_iff_unsupported_without_authority {result : Outcome α} {guarded} :
    route result guarded = .fixed ↔ result = .error .unsupported ∧ guarded = false := by
  cases result with
  | ok a => simp [route]
  | error e => cases e <;> cases guarded <;> simp [route]

theorem disagreement_has_no_fallback (guarded : Bool) :
    route (α:=α) (.error .disagreement) guarded = .rejected ∧
    route (α:=α) (.error .cycle) guarded = .rejected := by simp [route]

/-- Ordered effects extracted from all four checked adapter routes. -/
def effectProgram : List String := [
  "unsupported","lift-builtin-int","read-parser-family","atomic-return","guard-active-class","hard-error",
  "primitive-domain-check","unsupported","visit-each-canonical-child","unsupported","singleton-identity","choose-union-or-intersection",
  "compare-complete-occurrence-evidence","hard-error","return-derived","restore-path",
  "try-guarded-join","no-optional-authority","dependent-certificate",
  "no-optional-authority","guarded-certificate","fixed-node"]

def evalRegistered (effects : List String) (source : SourceGraph)
    (combine : Op → List Dag → Outcome Dag) (fuel : Nat) (active : List Nat) (i : Nat) : Outcome Return :=
  if effects = effectProgram then walk source combine fuel active i else .error .unsupported

theorem registered_source_agreement {effects : List String} {source : SourceGraph}
    {combine : Op → List Dag → Outcome Dag} {fuel active i v}
    (ok : evalRegistered effects source combine fuel active i = .ok v) :
    effects = effectProgram ∧ consistent v.checks ∧
      (match source i with | .atom p | .operation _ p _ => p) = some v.dag := by
  by_cases h : effects=effectProgram
  · refine ⟨h,recursive_parser_agreement source combine fuel active i ?_⟩
    simpa [evalRegistered,h] using ok
  · simp [evalRegistered,h] at ok

#print axioms eligible_success
#print axioms mixed_representation_refused
#print axioms registered_source_agreement
#print axioms collected_from_source
#print axioms finish_checks_every_child
#print axioms recursive_parser_agreement
#print axioms collected_at_each_index
#print axioms every_accepted_set_child
#print axioms matched_empty_keeps_parser_arity
#print axioms genuine_disagreement_blocks
#print axioms recursive_occurrence_blocks
#print axioms typed_empty_keeps_width
#print axioms fixed_iff_unsupported_without_authority
#print axioms disagreement_has_no_fallback

end A226

def main (args : List String) : IO UInt32 := do
  let [path] := args | return 64
  let effects := (← IO.FS.readFile path).trimAsciiEnd.toString.splitOn "\n"
  if effects = A226.effectProgram then
    IO.println "A226 complete source program accepted"
    return 0
  IO.println "A226 incomplete source program rejected"
  return 1
