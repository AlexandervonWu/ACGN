import Std

namespace A216

inductive Kind where | join | arrow deriving DecidableEq, Repr
inductive Attempt where | unsupported | accepted | disagreement deriving DecidableEq, Repr
inductive Rule where | tryGuard | plain deriving DecidableEq, Repr

structure Program where
  join : Rule
  arrow : Rule
  deriving DecidableEq

def registered : Program := ⟨.tryGuard, .plain⟩

def readRule : String → Option Rule
  | "guard" => some .tryGuard
  | "fixed" => some .plain
  | _ => none

def decode (lines : List String) : Option Program := do
  let [ids, init, arity, cache, j, a, fail, order, lawCheck, projection] := lines | none
  if ids != "reject-repeated-pristine-class-id" || init != "one-pristine-source-per-key" || arity != "arity-before-cache"
    || cache != "cache-before-attempt" || fail != "hard-before-fallback"
    || order != "for-child-append;for-port-append" || lawCheck != "fixed-empty-laws" || projection != "project-only-occurrence-bound-authority" then none
  else
    let ["JOIN",jr] := j.splitOn "=" | none
    let ["ARROW",ar] := a.splitOn "=" | none
    let x ← readRule jr
    let y ← readRule ar
    return ⟨x,y⟩

def programOK (lines : List String) : Bool := decide (decode lines = some registered)

theorem checked_program {xs : List String} (ok : programOK xs = true) :
    decode xs = some registered := by simpa [programOK] using ok

inductive Value (α : Type) where
  | fixed (kind : Kind) (orderedPorts : List α)
  | dependent (kind : Kind)
  | guarded
  deriving DecidableEq, Repr

structure Request (α : Type) where
  kind : Kind
  source : List α
  dependent : Attempt
  guarded : Attempt

def policy (p : Program) : Kind → Rule
  | .join => p.join
  | .arrow => p.arrow

-- A failed child, including a hard type disagreement, supplies no invocation.
def cold (p : Program) (r : Request α) (child : α → Option β) : Option (Value β) :=
  match r.source with
  | [l,h] =>
    let fixed := do
      let left ← child l
      let right ← child h
      return Value.fixed r.kind [left,right]
    match r.dependent with
    | .disagreement => none
    | .accepted => some (.dependent r.kind)
    | .unsupported =>
      match policy p r.kind, r.guarded with
      | .plain, _ | .tryGuard, .unsupported => fixed
      | .tryGuard, .accepted => some .guarded
      | .tryGuard, .disagreement => none
  | _ => none

def unlicensed (r : Request α) : Prop :=
  r.dependent = .unsupported ∧ (r.kind = .arrow ∨ r.guarded = .unsupported)

theorem fixed_iff (r : Request α) (child : α → Option β) (k : Kind) (ports : List β) :
    cold registered r child = some (.fixed k ports) ↔
    unlicensed r ∧ k = r.kind ∧ ∃ l h left right, r.source = [l,h] ∧
      child l = some left ∧ child h = some right ∧ ports = [left,right] := by
  rcases r with ⟨kind,xs,dep,gd⟩
  cases xs with
  | nil => simp [cold]
  | cons l more =>
    cases more with
    | nil => simp [cold]
    | cons h last =>
      cases last with
      | cons x xs => simp [cold]
      | nil =>
        cases kind <;> cases dep <;> cases gd <;>
          cases hl : child l <;> cases hr : child h <;>
          simp_all [cold, unlicensed, policy, registered, eq_comm, and_comm, and_left_comm] <;> grind

theorem exact_order (r : Request α) (child : α → Option β)
    (h : cold registered r child = some (.fixed k ps)) :
    ps.length = 2 ∧ r.source.mapM child = some ps := by
  obtain ⟨_,_,l,z,x,y,hs,hx,hy,rfl⟩ := (fixed_iff _ _ _ _).mp h
  simp [hs, hx, hy, List.mapM, List.mapM.loop]

theorem distinct_swap_detected (a b : α) (h : a ≠ b) :
    Value.fixed (α := α) k [a,b] ≠ .fixed k [b,a] := by
  intro e
  simp_all

def rootAuthority : Value α → Option Kind
  | .dependent k => some k
  | .guarded => some .join
  | .fixed _ _ => none

theorem fixed_without_root_authority (r : Request α) (child : α → Option β)
    (h : unlicensed r) (ok : cold registered r child = some v) : rootAuthority v = none := by
  rcases r with ⟨kind,xs,dep,gd⟩
  cases xs with
  | nil => simp [cold] at ok
  | cons l tail =>
    cases tail with
    | nil => simp [cold] at ok
    | cons u tail =>
      cases tail with
      | cons x xs => simp [cold] at ok
      | nil =>
        cases kind <;> cases dep <;> cases gd <;> cases hl : child l <;> cases hu : child u <;>
          simp_all [unlicensed,cold,registered,policy,rootAuthority] <;> subst v <;> rfl

theorem hard_no_fallback (kind : Kind) (xs : List α) (c : α → Option β) (gd : Attempt) :
    cold registered ⟨kind,xs,.disagreement,gd⟩ c = none := by
  cases xs with
  | nil => rfl
  | cons l xs => cases xs with
    | nil => rfl
    | cons h xs => cases xs <;> rfl

theorem separately_licensed_guard (l r : α) (child : α → Option β) :
    cold registered ⟨.join,[l,r],.unsupported,.accepted⟩ child = some .guarded := rfl

theorem plain_arrow_ignores_guard (l r : α) (child : α → Option β) (gd : Attempt) :
    cold registered ⟨.arrow,[l,r],.unsupported,gd⟩ child =
      (do let a ← child l; let b ← child r; pure (.fixed .arrow [a,b])) := rfl

-- A successful source census gives a checked inverse master representative for every e-class.
theorem pristine_key_injective (owner : σ → Nat) (rep : Nat → σ)
    (pristine : ∀ x, rep (owner x) = x) {x y : σ} (same : owner x = owner y) : x = y := by
  calc x = rep (owner x) := (pristine x).symm
       _ = rep (owner y) := congrArg rep same
       _ = y := pristine y

-- Each cached invocation belongs to a ranked input's complete evaluation. Hits do not issue proofs.
abbrev Memo (α : Type) := Nat → Option (Value α)

def visit (arityOK : Nat → Bool) (evaluate : Nat → Option (Value α))
    (m : Memo α) (key : Nat) : Option (Value α) × Memo α :=
  if arityOK key then
    match m key with
    | some v => (some v,m)
    | none =>
      match evaluate key with
      | none => (none,m)
      | some v => (some v,fun i => if i = key then some v else m i)
  else (none,m)

def sound (m : Memo α) (evaluate : Nat → Option (Value α)) : Prop :=
  ∀ i v, m i = some v → evaluate i = some v

theorem visit_preserves (a : Nat → Bool) (f : Nat → Option (Value α))
    (m : Memo α) (k : Nat) (s : sound m f) : sound (visit a f m k).2 f := by
  intro i v h
  by_cases ar : a k = true
  · cases remembered : m k with
    | some prior => exact s i v (by simpa [visit,ar,remembered] using h)
    | none =>
      cases coldResult : f k with
      | none => exact s i v (by simpa [visit,ar,remembered,coldResult] using h)
      | some w =>
        by_cases eq : i = k
        · subst i
          simp_all [visit]
        · exact s i v (by simpa [visit,ar,remembered,coldResult,eq] using h)
  · exact s i v (by simpa [visit,ar] using h)

def replay (a : Nat → Bool) (f : Nat → Option (Value α)) (history : List Nat) : Memo α :=
  history.foldl (fun m k => (visit a f m k).2) (fun _ => none)

theorem arbitrary_history_sound (a : Nat → Bool) (f : Nat → Option (Value α)) (history : List Nat) :
    sound (replay a f history) f := by
  have aux (xs : List Nat) (m : Memo α) (hm : sound m f) :
      sound (xs.foldl (fun z k => (visit a f z k).2) m) f := by
    induction xs generalizing m with
    | nil => exact hm
    | cons k ks ih => exact ih _ (visit_preserves _ _ _ _ hm)
  exact aux _ _ (by simp [sound])

theorem hit_observes_cold (a : Nat → Bool) (f : Nat → Option (Value α)) (keys : List Nat) (k : Nat)
    (accepted : a k = true) : (visit a f (replay a f keys) k).1 = f k := by
  cases hk : replay a f keys k with
  | none => cases h : f k <;> simp [visit,accepted,hk,h]
  | some v => simp [visit,accepted,hk,(arbitrary_history_sound a f keys k v hk)]

theorem unchecked_arity_refused (a : Nat → Bool) (f : Nat → Option (Value α)) (keys : List Nat) (k : Nat)
    (no : a k = false) : (visit a f (replay a f keys) k).1 = none := by simp [visit,no]

theorem checked_dispatch_fallback (lines : List String) (checked : programOK lines = true)
    (a : Nat → Bool) (requests : Nat → Request α) (operand : Nat → α → Option β)
    (hist : List Nat) (k : Nat) (ok : a k = true) (op : Kind) (ports : List β) :
    ∃ p, decode lines = some p ∧
      ((visit a (fun i => cold p (requests i) (operand i))
        (replay a (fun i => cold p (requests i) (operand i)) hist) k).1 = some (.fixed op ports) ↔
        unlicensed (requests k) ∧ op = (requests k).kind ∧
        ∃ l r left right, (requests k).source = [l,r] ∧ operand k l = some left ∧
          operand k r = some right ∧ ports = [left,right]) := by
  refine ⟨registered,checked_program checked,?_⟩
  rw [hit_observes_cold _ _ _ _ ok]
  exact fixed_iff _ _ _ _

def census (seen : List Nat) : List Nat → Bool
  | [] => true
  | k::ks => !(seen.contains k) && census (k::seen) ks

theorem census_iff (seen keys : List Nat) : census seen keys = true ↔
    keys.Nodup ∧ ∀ k ∈ keys, k ∉ seen := by
  induction keys generalizing seen with
  | nil => simp [census]
  | cons k ks ih =>
    simp [census, ih, List.nodup_cons]
    grind

theorem admitted_key_unique (keys : List Nat) (ok : census [] keys = true)
    {i j : Nat} (hi : i < keys.length) (hj : j < keys.length) (same : keys[i] = keys[j]) : i = j :=
  ((census_iff [] keys).mp ok).1.eq_of_getElem_eq hi hj same

theorem duplicate_refused (k : Nat) : census [] [k,k] = false := by simp [census]

theorem pristine_cached_fallback (lines : List String) (checked : programOK lines = true)
    (key : σ → Nat) (sourceOf : Nat → σ) (pristine : ∀ s, sourceOf (key s) = s)
    (a : Nat → Bool) (requests : σ → Request α) (operand : σ → α → Option β)
    (hist : List Nat) (site : σ) (ok : a (key site) = true) (op : Kind) (ports : List β) :
    ∃ p, decode lines = some p ∧
      ((visit a (fun i => cold p (requests (sourceOf i)) (operand (sourceOf i)))
        (replay a (fun i => cold p (requests (sourceOf i)) (operand (sourceOf i))) hist) (key site)).1 =
        some (.fixed op ports) ↔ unlicensed (requests site) ∧ op = (requests site).kind ∧
        ∃ l r left right, (requests site).source = [l,r] ∧ operand site l = some left ∧
          operand site r = some right ∧ ports = [left,right]) := by
  simpa only [pristine] using (checked_dispatch_fallback lines checked a
    (fun i => requests (sourceOf i)) (fun i => operand (sourceOf i)) hist (key site) ok op ports)

noncomputable def sourceAt (keys : List Nat) (fallback : Fin keys.length) (k : Nat) :
    Fin keys.length := by
  classical
  exact if h : ∃ p : Fin keys.length, keys[p.val] = k then Classical.choose h else fallback

theorem census_source_inverse (keys : List Nat) (verified : census [] keys = true)
    (fallback site : Fin keys.length) : sourceAt keys fallback keys[site.val] = site := by
  classical
  have h : ∃ p : Fin keys.length, keys[p.val] = keys[site.val] := ⟨site,rfl⟩
  simp only [sourceAt, dite_eq_left h]
  apply Fin.ext
  exact admitted_key_unique keys verified _ _ (Classical.choose_spec h)

theorem registered_site_fallback (lines : List String) (checked : programOK lines = true)
    (keys : List Nat) (verified : census [] keys = true) (site : Fin keys.length)
    (a : Nat → Bool) (requests : Fin keys.length → Request α) (operand : Fin keys.length → α → Option β)
    (hist : List Nat) (ok : a keys[site.val] = true) (op : Kind) (ports : List β) :
    ∃ p, decode lines = some p ∧
      ((visit a (fun i => cold p (requests (sourceAt keys site i)) (operand (sourceAt keys site i)))
        (replay a (fun i => cold p (requests (sourceAt keys site i)) (operand (sourceAt keys site i)))
          hist) keys[site.val]).1 = some (.fixed op ports) ↔ unlicensed (requests site) ∧
        op = (requests site).kind ∧ ∃ l r left right, (requests site).source = [l,r] ∧
        operand site l = some left ∧ operand site r = some right ∧ ports = [left,right]) := by
  exact pristine_cached_fallback lines checked (fun p : Fin keys.length => keys[p.val])
    (sourceAt keys site) (census_source_inverse keys verified site) a requests operand hist site ok op ports

#print axioms census_source_inverse
#print axioms registered_site_fallback
#print axioms census_iff
#print axioms admitted_key_unique
#print axioms duplicate_refused
#print axioms pristine_cached_fallback
#print axioms checked_program
#print axioms fixed_iff
#print axioms exact_order
#print axioms distinct_swap_detected
#print axioms fixed_without_root_authority
#print axioms hard_no_fallback
#print axioms separately_licensed_guard
#print axioms plain_arrow_ignores_guard
#print axioms pristine_key_injective
#print axioms visit_preserves
#print axioms arbitrary_history_sound
#print axioms hit_observes_cold
#print axioms unchecked_arity_refused
#print axioms checked_dispatch_fallback
end A216

def main (args : List String) : IO UInt32 := do
  if let ["--class-ids",f] := args then
    let entries := (← IO.FS.readFile f).trimAscii.toString.splitOn "\n"
    let some keys := entries.mapM String.toNat? | return 2
    if A216.census [] keys then
      IO.println "A216 source identifiers accepted"
      return 0
    IO.println "A216 source identifiers rejected"
    return 1
  let [f] := args | return 2
  if A216.programOK ((← IO.FS.readFile f).trimAscii.toString.splitOn "\n") then
    IO.println "A216 compiler dispatch accepted"
    return 0
  IO.println "A216 compiler dispatch rejected"
  return 1
