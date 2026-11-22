import P506SourceNonempty

namespace ACGN.Tenth.P511

open P506SourceNonempty

/-- The parser coordinate and evidence are independent of its current printed name.
    Newer frames precede older ones. An empty entry shadows an older binding. -/
structure Entry where
  name : Nat
  coordinate : Nat
  token : Option Slot

def resolve : List Entry → Nat → Option Entry
  | [], _ => none
  | e :: rest, n => if e.name = n then some e else resolve rest n

def named (e : Entry) : Frame := ⟨e.name, e.token⟩

/-- A free spelling and an allocated binder belong to disjoint name spaces.
    The slotted implementation uses fresh strings; only equality is observable here. -/
def assigned (serial : Nat) := 2 * serial
def unbound (name : Nat) := 2 * name + 1

def render (permutation : Nat → Nat) (e : Entry) : Frame :=
  ⟨assigned (permutation e.coordinate), e.token⟩

def currentName (p : Nat → Nat) (scope : List Entry) (n : Nat) :=
  match resolve scope n with
  | none => unbound n
  | some e => assigned (p e.coordinate)

theorem named_lookup (scope : List Entry) (n : Nat) :
    lookup (scope.map named) n = (resolve scope n).bind Entry.token := by
  induction scope with
  | nil => rfl
  | cons e es ih =>
    by_cases h : e.name = n <;> simp [lookup, named, resolve, h, ih]

theorem resolved_member {scope : List Entry} {n : Nat} {e : Entry}
    (hit : resolve scope n = some e) : e ∈ scope := by
  induction scope with
  | nil => simp [resolve] at hit
  | cons f fs ih =>
    by_cases h : f.name = n
    · have hf : f = e := Option.some.inj (by simpa [resolve,h] using hit)
      simp [hf]
    · exact List.mem_cons_of_mem _ (ih (by simpa [resolve,h] using hit))

theorem missing_coordinate (p : Nat → Nat) (injects : ∀ {a b}, p a = p b → a = b)
    (scope : List Entry) (i : Nat) (absent : i ∉ scope.map Entry.coordinate) :
    lookup (scope.map (render p)) (assigned (p i)) = none := by
  induction scope with
  | nil => rfl
  | cons f fs ih =>
    have miss : f.coordinate ≠ i := by intro h; exact absent (by simp [h])
    have off : assigned (p f.coordinate) ≠ assigned (p i) := by
      intro eq
      apply miss
      apply injects
      unfold assigned at eq
      omega
    simp [lookup, render, off, ih (by intro h; exact absent (List.mem_cons_of_mem _ h))]

theorem lookup_coordinate (p : Nat → Nat) (injects : ∀ {a b}, p a = p b → a = b)
    {scope : List Entry} {e : Entry} (unique : (scope.map Entry.coordinate).Nodup)
    (member : e ∈ scope) :
    lookup (scope.map (render p)) (assigned (p e.coordinate)) = e.token := by
  induction scope with
  | nil => simp at member
  | cons f fs ih =>
    obtain ⟨fresh, rest⟩ := List.nodup_cons.mp unique
    rcases List.mem_cons.mp member with h | tail
    · subst e; simp [lookup,render]
    · have different : f.coordinate ≠ e.coordinate := by
        intro eq
        apply fresh
        rw [eq]
        exact List.mem_map.mpr ⟨e,tail,rfl⟩
      have off : assigned (p f.coordinate) ≠ assigned (p e.coordinate) := by
        intro eq
        apply different
        apply injects
        unfold assigned at eq
        omega
      simpa [lookup,render,off] using ih rest tail

theorem free_lookup (p : Nat → Nat) (scope : List Entry) (n : Nat) :
    lookup (scope.map (render p)) (unbound n) = none := by
  induction scope with
  | nil => rfl
  | cons f fs ih =>
    have off : assigned (p f.coordinate) ≠ unbound n := by unfold assigned unbound; omega
    simp [lookup,render,off,ih]

/-- After lexicalization the representative may permute whole independent
    declaration entries. Equal spellings at different source scopes need distinct
    allocated coordinates, but the source spellings themselves may coincide. -/
theorem transport_lookup (p : Nat → Nat) (injects : ∀ {a b}, p a = p b → a = b)
    (scope reordered : List Entry) (order : scope.Perm reordered)
    (unique : (scope.map Entry.coordinate).Nodup) (n : Nat) :
    lookup (reordered.map (render p)) (currentName p scope n) =
      lookup (scope.map named) n := by
  rw [named_lookup]
  cases seen : resolve scope n with
  | none => simpa [currentName,seen] using free_lookup p reordered n
  | some e =>
    have m := order.mem_iff.mp (resolved_member seen)
    have hu := (order.map Entry.coordinate).nodup_iff.mp unique
    simpa [currentName,seen] using lookup_coordinate p injects hu m

theorem shadow_selects_inner (inner : Entry) (outer : List Entry) :
    resolve (inner :: outer) inner.name = some inner := by simp [resolve]

theorem nullable_shadow_blocks (r : Root) (name coordinate : Nat) (rest : List Entry)
    (read : Option Slot) :
    authorize r ((⟨name, coordinate, none⟩ :: rest).map named) name read = false := by
  exact shadow_blocks_outer r (rest.map named) name read

theorem fresh_extension (scope : List Entry) (e : Entry)
    (fresh : e.coordinate ∉ scope.map Entry.coordinate)
    (prior : (scope.map Entry.coordinate).Nodup) :
    ((e :: scope).map Entry.coordinate).Nodup := List.nodup_cons.mpr ⟨fresh,prior⟩

/-- Domain expressions see the incoming environment; a committed declaration is
    visible only in its continuation. Lexical exit uses the persistent outer stack. -/
def enter (outer : List Entry) (current : Entry) (domainUse bodyUse : Nat) :=
  (resolve outer domainUse, resolve (current :: outer) bodyUse)

theorem domain_precedes_shadow (outer : List Entry) (e : Entry) :
    enter outer e e.name e.name = (resolve outer e.name, some e) := by
  simp [enter,resolve]

inductive Method where
  | raw | rawDeBruijn | egglog | egglogDeBruijn | slotted | typedSlotted
  deriving DecidableEq

/-- De Bruijn is a storage projection. The four raw/egglog methods run the
    guard on the named frontier. Only slotted methods guard the renamed frontier. -/
def dispatch (method : Method) (r : Root) (p : Nat → Nat) (scope reordered : List Entry)
    (n : Nat) (read : Option Slot) :=
  match method with
  | .slotted | .typedSlotted =>
    authorize r (reordered.map (render p)) (currentName p scope n) read
  | .raw | .rawDeBruijn | .egglog | .egglogDeBruijn => authorize r (scope.map named) n read

theorem cross_engine_guard (method : Method) (r : Root) (p : Nat → Nat)
    (injects : ∀ {a b}, p a = p b → a = b) (scope reordered : List Entry)
    (order : scope.Perm reordered) (unique : (scope.map Entry.coordinate).Nodup)
    (n : Nat) (read : Option Slot) :
    dispatch method r p scope reordered n read = authorize r (scope.map named) n read := by
  have same := transport_lookup p injects scope reordered order unique n
  cases method <;> simp [dispatch,authorize,same]

theorem authorized_has_current_coordinate (method : Method) (r : Root) (p : Nat → Nat)
    (injects : ∀ {a b}, p a = p b → a = b) (scope reordered : List Entry)
    (order : scope.Perm reordered) (unique : (scope.map Entry.coordinate).Nodup)
    (n : Nat) (read : Option Slot)
    (accepted : dispatch method r p scope reordered n read = true) :
    ∃ slot d, read = some slot ∧ Visible n slot (scope.map named) ∧ Issued r slot d ∧
      (effective d = .one ∨ effective d = .some) := by
  rw [cross_engine_guard method r p injects scope reordered order unique] at accepted
  exact authorized_has_original r (scope.map named) n read accepted

theorem synthetic_label_has_no_authority (method : Method) (r : Root) (p : Nat → Nat)
    (injects : ∀ {a b}, p a = p b → a = b) (scope reordered : List Entry)
    (order : scope.Perm reordered) (unique : (scope.map Entry.coordinate).Nodup) (n : Nat) :
    dispatch method r p scope reordered n none = false := by
  rw [cross_engine_guard method r p injects scope reordered order unique]
  exact missing_read_never_authorizes .. 

/-- Slot permutations arise by a finite sequence of transpositions of allocated
    coordinates. Each transposition is its own inverse on the entire namespace. -/
def transpose (a b n : Nat) : Nat := if n = a then b else if n = b then a else n

theorem transpose_twice (a b n : Nat) : transpose a b (transpose a b n) = n := by
  by_cases h : a = b
  · subst b; by_cases hna : n = a <;> simp [transpose,hna]
  · have h' := Ne.symm h
    by_cases hn : n = a
    · subst n; simp [transpose,h']
    · by_cases hm : n = b <;> simp [transpose,hn,hm,h']

def permute : List (Nat × Nat) → Nat → Nat
  | [], n => n
  | (a,b) :: tail, n => permute tail (transpose a b n)

theorem permute_injective (swaps : List (Nat × Nat)) {a b : Nat}
    (eq : permute swaps a = permute swaps b) : a = b := by
  induction swaps generalizing a b with
  | nil => exact eq
  | cons s tail ih =>
    obtain ⟨x,y⟩ := s
    have hs := congrArg (transpose x y) (ih eq)
    simpa [transpose_twice] using hs

def Below (next : Nat) (scope : List Entry) : Prop :=
  ∀ e ∈ scope, e.coordinate < next

theorem allocate_next (scope : List Entry) (next name : Nat) (token : Option Slot)
    (bound : Below next scope) (unique : (scope.map Entry.coordinate).Nodup) :
    let e : Entry := ⟨name,next,token⟩
    ((e :: scope).map Entry.coordinate).Nodup ∧ Below (next+1) (e :: scope) := by
  dsimp
  constructor
  · apply fresh_extension _ _ _ unique
    intro mem
    obtain ⟨older,hm,he⟩ := List.mem_map.mp mem
    have hb := bound older hm
    simp at he
    omega
  · intro f hf
    rcases List.mem_cons.mp hf with rfl | member
    · simp
    · have hb := bound f member
      omega

theorem generated_guard_has_current_coordinate (method : Method) (r : Root)
    (swaps : List (Nat × Nat)) (scope reordered : List Entry)
    (order : scope.Perm reordered) (unique : (scope.map Entry.coordinate).Nodup)
    (n : Nat) (read : Option Slot)
    (accepted : dispatch method r (permute swaps) scope reordered n read = true) :
    ∃ slot d, read = some slot ∧ Visible n slot (scope.map named) ∧ Issued r slot d ∧
      (effective d = .one ∨ effective d = .some) :=
  authorized_has_current_coordinate method r _ (permute_injective swaps)
    scope reordered order unique n read accepted

/-- A sampled frontier carries its actual printed keys and the original tokens of
    all active binders. The source declaration coordinate census must survive. -/
def sameCoordinate (scope : List Entry) (name : Nat) (read : Option Slot) : Bool :=
  read.isNone || (lookup (scope.map named) name == read)

def checkFrontiers (root : Root) (before after : List Entry) (keyBefore keyAfter : Nat)
    (read : Option Slot) (sourcePositive : Bool) : Bool :=
  decide ((before.map Entry.coordinate).Nodup ∧ (after.map Entry.coordinate).Nodup ∧
    (before.map Entry.coordinate).Perm (after.map Entry.coordinate)) &&
  (authorize root (before.map named) keyBefore read == sourcePositive) &&
  (authorize root (after.map named) keyAfter read == sourcePositive) &&
  sameCoordinate before keyBefore read && sameCoordinate after keyAfter read

theorem checked_frontiers_share_guard (root : Root) (before after : List Entry)
    (k k' : Nat) (read : Option Slot) (expected : Bool)
    (ok : checkFrontiers root before after k k' read expected = true) :
    (before.map Entry.coordinate).Perm (after.map Entry.coordinate) ∧
      authorize root (before.map named) k read = expected ∧
      authorize root (after.map named) k' read = expected := by
  simp [checkFrontiers] at ok
  exact ⟨ok.1.1.1.1.2.2,ok.1.1.1.2,ok.1.1.2⟩

theorem checked_nullable_or_positive_owner (root : Root) (before after : List Entry)
    (k k' : Nat) (slot : Slot) (expected : Bool)
    (ok : checkFrontiers root before after k k' (some slot) expected = true) :
    Visible k slot (before.map named) ∧ Visible k' slot (after.map named) := by
  simp [checkFrontiers,sameCoordinate] at ok
  exact ⟨lookup_visible ok.1.2,lookup_visible ok.2⟩

theorem checked_positive_same_original (root : Root) (before after : List Entry)
    (k k' : Nat) (read : Option Slot)
    (ok : checkFrontiers root before after k k' read true = true) :
    ∃ s d, read = some s ∧ Visible k s (before.map named) ∧ Visible k' s (after.map named) ∧
      Issued root s d ∧ (effective d = .one ∨ effective d = .some) := by
  obtain ⟨_,original,transformed⟩ := checked_frontiers_share_guard _ _ _ _ _ _ _ ok
  obtain ⟨s,d,h,visible,issued,pos⟩ := authorized_has_original _ _ _ _ original
  obtain ⟨s',_,h',visible',_,_⟩ := authorized_has_original _ _ _ _ transformed
  rw [h] at h'
  have eq := Option.some.inj h'
  subst s'
  exact ⟨s,d,h,visible,visible',issued,pos⟩

/-- Before substitution a binder whose spelling occurs free in the replacement
    receives a fresh spelling. The token is transported through the rename. The
    concrete counter skips every used name; the abstract order supplies fresh
    names above the protected replacement and the preceding allocation. -/
def protect (replacement next : Nat) : List Frame → List Frame
  | [] => []
  | f :: tail =>
    let fresh := max next replacement + 1
    let g : Frame := if f.name = replacement then ⟨fresh,f.slot⟩ else f
    g :: protect replacement fresh tail

theorem protected_prefix_keeps_lookup (replacement next : Nat) (locals outer : List Frame) :
    lookup (protect replacement next locals ++ outer) replacement = lookup outer replacement := by
  induction locals generalizing next with
  | nil => rfl
  | cons f tail ih =>
    have different : max next replacement + 1 ≠ replacement := by omega
    by_cases hit : f.name = replacement <;> simp [protect,lookup,hit,different,ih]

def replacementAt (visible : Bool) (target : Nat) (leaf replacement : Nat × Option Slot) :=
  if visible && leaf.1 == target then replacement else leaf

theorem shadow_withholds_substitution (target : Nat) (leaf replacement : Nat × Option Slot) :
    replacementAt false target leaf replacement = leaf := by simp [replacementAt]

/-- The aliased occurrence receives its parsed RHS token. Free-variable
    protection makes its decision equal the one at the RHS's lexical origin. -/
theorem substitution_transports_original (r : Root) (locals outer : List Frame)
    (alias rhs next : Nat) (aliasToken rhsToken : Option Slot) :
    let replaced := replacementAt true alias (alias,aliasToken) (rhs,rhsToken)
    authorize r (protect rhs next locals ++ outer) replaced.1 replaced.2 =
      authorize r outer rhs rhsToken := by
  simp [replacementAt,authorize,protected_prefix_keeps_lookup]

end ACGN.Tenth.P511

#print axioms ACGN.Tenth.P511.named_lookup
#print axioms ACGN.Tenth.P511.resolved_member
#print axioms ACGN.Tenth.P511.missing_coordinate
#print axioms ACGN.Tenth.P511.lookup_coordinate
#print axioms ACGN.Tenth.P511.free_lookup
#print axioms ACGN.Tenth.P511.transport_lookup
#print axioms ACGN.Tenth.P511.shadow_selects_inner
#print axioms ACGN.Tenth.P511.nullable_shadow_blocks
#print axioms ACGN.Tenth.P511.fresh_extension
#print axioms ACGN.Tenth.P511.domain_precedes_shadow
#print axioms ACGN.Tenth.P511.cross_engine_guard
#print axioms ACGN.Tenth.P511.authorized_has_current_coordinate
#print axioms ACGN.Tenth.P511.synthetic_label_has_no_authority
#print axioms ACGN.Tenth.P511.transpose_twice
#print axioms ACGN.Tenth.P511.permute_injective
#print axioms ACGN.Tenth.P511.allocate_next
#print axioms ACGN.Tenth.P511.generated_guard_has_current_coordinate
#print axioms ACGN.Tenth.P511.checked_frontiers_share_guard
#print axioms ACGN.Tenth.P511.checked_positive_same_original

#print axioms ACGN.Tenth.P511.checked_nullable_or_positive_owner
#print axioms ACGN.Tenth.P511.protected_prefix_keeps_lookup
#print axioms ACGN.Tenth.P511.shadow_withholds_substitution
#print axioms ACGN.Tenth.P511.substitution_transports_original
