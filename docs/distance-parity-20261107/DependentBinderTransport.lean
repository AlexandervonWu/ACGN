import CrossReferenceSelection

namespace DependentBinderTransport
open EndpointCanonicalContracts
open CrossReferenceSelection

def update (env : Ref → V) (r : Ref) (value : V) : Ref → V :=
  fun q => if q = r then value else env q

theorem renamed_ref_eq (owner : Nat) (p : Permutation) (q r : Ref) :
    renameRef owner p.backward q = r ↔ q = renameRef owner p.forward r := by
  constructor
  · intro h
    have mapped := congrArg (renameRef owner p.forward) h
    have inverse : renameRef owner p.forward (renameRef owner p.backward q) = q :=
      rename_inverse owner (reverse p) q
    rwa [inverse] at mapped
  · intro h
    rw [h, rename_inverse]

theorem update_transport (owner : Nat) (p : Permutation) (env : Ref → V)
    (r : Ref) (value : V) :
    update (transport owner p.backward env) (renameRef owner p.forward r) value =
      transport owner p.backward (update env r value) := by
  funext q
  simp only [update, transport, renamed_ref_eq owner p q r]

-- Binder interpretations receive the domain and the complete value-to-body
-- function. The theorem does not reorder quantifiers, assume nonempty domains,
-- exchange output columns, or change the interpretation of any operator.
inductive ScopedExpr (V : Type) where
  | plain : Expr V → ScopedExpr V
  | unary : (V → V) → ScopedExpr V → ScopedExpr V
  | binary : (V → V → V) → ScopedExpr V → ScopedExpr V → ScopedExpr V
  | bind : (V → (V → V) → V) → Ref → ScopedExpr V → ScopedExpr V → ScopedExpr V

def denote (env : Ref → V) : ScopedExpr V → V
  | .plain e => eval env e
  | .unary f e => f (denote env e)
  | .binary f a b => f (denote env a) (denote env b)
  | .bind f r domain body =>
      f (denote env domain) (fun value => denote (update env r value) body)

def renameScoped (owner : Nat) (p : Nat → Nat) : ScopedExpr V → ScopedExpr V
  | .plain e => .plain (rename owner p e)
  | .unary f e => .unary f (renameScoped owner p e)
  | .binary f a b => .binary f (renameScoped owner p a) (renameScoped owner p b)
  | .bind f r domain body => .bind f (renameRef owner p r)
      (renameScoped owner p domain) (renameScoped owner p body)

theorem whole_binder_transport (owner : Nat) (p : Permutation)
    (e : ScopedExpr V) (env : Ref → V) :
    denote (transport owner p.backward env) (renameScoped owner p.forward e) =
      denote env e := by
  induction e generalizing env with
  | plain e => exact body_transport owner p env e
  | unary f e ih => exact congrArg f (ih env)
  | binary f a b ha hb => simp only [renameScoped, denote, ha, hb]
  | bind f r domain body hd hb =>
      simp only [renameScoped, denote, hd]
      congr 1
      funext value
      rw [update_transport]
      exact hb (update env r value)

theorem whole_binder_transport_reverse (owner : Nat) (p : Permutation)
    (e : ScopedExpr V) (env : Ref → V) :
    denote (transport owner p.forward env) (renameScoped owner p.backward e) =
      denote env e := whole_binder_transport owner (reverse p) e env

def reads : Expr V → List Ref
  | .var r => [r]
  | .value _ => []
  | .unary _ a => reads a
  | .binary _ a b => reads a ++ reads b

theorem ordered_reads_transport (owner : Nat) (p : Nat → Nat) (e : Expr V) :
    reads (rename owner p e) = (reads e).map (renameRef owner p) := by
  induction e with
  | var r => rfl
  | value v => rfl
  | unary f a ih => exact ih
  | binary f a b ha hb => simp only [rename, reads, ha, hb, List.map_append]

theorem repeated_reads_retained (owner slot : Nat) (p : Nat → Nat) :
    ([Ref.mk owner slot, Ref.mk owner slot]).map (renameRef owner p) =
      [Ref.mk owner (p slot), Ref.mk owner (p slot)] := by
  simp [renameRef]

theorem foreign_reads_fixed (owner : Nat) (p : Nat → Nat) (r : Ref)
    (h : r.owner ≠ owner) : renameRef owner p r = r := foreign_owner_unchanged h

def freeReads : ScopedExpr V → List Ref
  | .plain e => reads e
  | .unary _ e => freeReads e
  | .binary _ a b => freeReads a ++ freeReads b
  | .bind _ r domain body => freeReads domain ++ (freeReads body).filter (fun q => q != r)

theorem eval_congr_reads (e : Expr V) (a b : Ref → V)
    (h : ∀ r ∈ reads e, a r = b r) : eval a e = eval b e := by
  induction e with
  | var r => exact h r (by simp [reads])
  | value v => rfl
  | unary f e ih => exact congrArg f (ih h)
  | binary f x y hx hy =>
      have left := hx (fun r hr => h r (by simp [reads, hr]))
      have right := hy (fun r hr => h r (by simp [reads, hr]))
      simp only [eval, left, right]

theorem denote_congr_free (e : ScopedExpr V) (a b : Ref → V)
    (h : ∀ r ∈ freeReads e, a r = b r) : denote a e = denote b e := by
  induction e generalizing a b with
  | plain e => exact eval_congr_reads e a b h
  | unary f e ih => exact congrArg f (ih a b h)
  | binary f x y hx hy =>
      have left := hx a b (fun r hr => h r (by simp [freeReads, hr]))
      have right := hy a b (fun r hr => h r (by simp [freeReads, hr]))
      simp only [denote, left, right]
  | bind f r domain body hd hb =>
      simp only [denote]
      have domains := hd a b (fun q hq => h q (by simp [freeReads, hq]))
      rw [domains]
      congr 1
      funext value
      apply hb
      intro q hq
      by_cases eq : q = r
      · simp [update, eq]
      · simp only [update, ite_eq_right eq]
        exact h q (by simp [freeReads, hq, eq])

-- The executable scope check must establish this premise: a moved coordinate
-- is never a free read, including a read in its own/earlier declaration domain.
theorem closed_binder_same_environment (owner : Nat) (p : Permutation)
    (e : ScopedExpr V) (env : Ref → V)
    (closed : ∀ r ∈ freeReads e, renameRef owner p.forward r = r) :
    denote env (renameScoped owner p.forward e) = denote env e := by
  have renamed := whole_binder_transport owner p e (transport owner p.forward env)
  rw [transport_inverse_other] at renamed
  refine renamed.trans (denote_congr_free e _ env ?_)
  intro r hr
  simp only [transport, closed r hr]

-- Edge maps are conjugated, not assumed to be identity. The condition is also
-- checked when a copy preserves an unchanged edge map that commutes with p.
def moveInvocation (owner : Nat) (p : Permutation) (edge : Ref → Ref) : Ref → Ref :=
  fun r => renameRef owner p.forward (edge (renameRef owner p.backward r))

theorem invocation_commutes (owner : Nat) (p : Permutation) (edge : Ref → Ref) (r : Ref) :
    moveInvocation owner p edge (renameRef owner p.forward r) =
      renameRef owner p.forward (edge r) := by
  simp only [moveInvocation, rename_inverse]

theorem effective_invocation_read (owner : Nat) (p : Permutation)
    (edge : Ref → Ref) (env : Ref → V) (r : Ref) :
    transport owner p.backward env
      (moveInvocation owner p edge (renameRef owner p.forward r)) = env (edge r) := by
  simp only [invocation_commutes, transport, rename_inverse]

theorem open_read_not_closed :
    ¬ (∀ r ∈ freeReads (ScopedExpr.plain (Expr.var (V := Nat) ⟨0, 0⟩)),
      renameRef 0 swap.forward r = r) := by
  intro h
  have bad := h ⟨0, 0⟩ (by simp [freeReads, reads])
  have slots := congrArg Ref.slot bad
  simp [renameRef, swap, swap01] at slots

-- This is transport to a NEW dependent frame, not an automorphism of a
-- fixed frame. Relative domain syntax is unchanged; its ordered inputs move.
def moveFrame (p : Nat → Nat) (f : Frame) : Frame :=
  { f with dependencies := f.dependencies.map p }

def moveFrames (p : Permutation) (frames : Nat → Frame) : Nat → Frame :=
  fun j => moveFrame p.forward (frames (p.backward j))

theorem moved_header (p : Permutation) (frames : Nat → Frame) (i : Nat) :
    header (moveFrames p frames (p.forward i)) = header (frames i) := by
  simp [moveFrames, moveFrame, header, p.leftInverse]

theorem moved_dependency_reads (p : Permutation) (frames : Nat → Frame)
    (env : Nat → V) (i : Nat) :
    (moveFrames p frames (p.forward i)).dependencies.map (fun j => env (p.backward j)) =
      (frames i).dependencies.map env := by
  simp [moveFrames, moveFrame, List.map_map, Function.comp_def, p.leftInverse]

theorem moved_domain_sound (p : Permutation) (frames : Nat → Frame)
    (interpret : Nat → List V → V → Prop) (env : Nat → V) (i : Nat) :
    domainHolds (moveFrames p frames) interpret (fun j => env (p.backward j)) (p.forward i) ↔
      domainHolds frames interpret env i := by
  simp only [domainHolds, moved_dependency_reads]
  simp [moveFrames, moveFrame, p.leftInverse]

structure checkedTransport (frames target : Nat → Frame) (p : Permutation) (n : Nat) : Prop where
  within : ∀ i, i < n → p.forward i < n ∧ p.backward i < n
  outside : ∀ i, n ≤ i → p.forward i = i ∧ p.backward i = i
  payload : ∀ i, i < n → header (frames (p.forward i)) = header (frames i)
  targetFrame : ∀ i, i < n → target (p.forward i) = moveFrame p.forward (frames i)

theorem checked_domain_sound (frames target : Nat → Frame) (p : Permutation) (n : Nat)
    (h : checkedTransport frames target p n) (interpret : Nat → List V → V → Prop)
    (env : Nat → V) (i : Nat) (hi : i < n) :
    domainHolds target interpret (fun j => env (p.backward j)) (p.forward i) ↔
      domainHolds frames interpret env i := by
  simp only [domainHolds, h.targetFrame i hi, moveFrame, List.map_map, Function.comp_def,
    p.leftInverse]

theorem checked_owner_phase_type (frames target : Nat → Frame) (p : Permutation)
    (n : Nat) (h : checkedTransport frames target p n) (i : Nat) (hi : i < n) :
    (target (p.forward i)).owner = (frames i).owner ∧
    (target (p.forward i)).phase = (frames i).phase ∧
    (target (p.forward i)).type = (frames i).type := by
  simp [h.targetFrame i hi, moveFrame]

-- Concrete source: socialMedia/correct/frYeGpTJ6HqHkkAPG_inv7.als.
def sourceSha256 : String := "a955443775d28c73d68f7810c618c3cf81995f83c3b882b8ed92467fdea59153"
def socialFrames (i : Nat) : Frame :=
  if i = 2 then ⟨1, 0, 1, 1, [0, 0]⟩ else ⟨0, 0, 1, 0, []⟩

-- Exactly the dependency/owner conjunct added to FastBinderOrbit, with the
-- existing payload (type, domain, multiplicity/group) equality retained.
def oldDependencyGate (frames : Nat → Frame) (p : Permutation) (n : Nat) : Prop :=
  ∀ i, i < n → (frames i).owner = (frames (p.forward i)).owner ∧
    (frames i).dependencies.length = (frames (p.forward i)).dependencies.length ∧
    (frames i).dependencies.map p.forward = (frames (p.forward i)).dependencies

def oldGate (frames : Nat → Frame) (p : Permutation) (n : Nat) : Prop :=
  (∀ i, i < n → header (frames (p.forward i)) = header (frames i)) ∧
    oldDependencyGate frames p n

theorem social_old_dependency_gate_rejects : ¬ oldDependencyGate socialFrames swap 3 := by
  intro h
  have bad := (h 2 (by decide)).2.2
  simp [socialFrames, swap, swap01] at bad

theorem social_old_gate_rejects : ¬ oldGate socialFrames swap 3 := by
  exact fun h => social_old_dependency_gate_rejects h.2

theorem social_checked_transport :
    checkedTransport socialFrames (moveFrames swap socialFrames) swap 3 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro i hi
    have cases : i = 0 ∨ i = 1 ∨ i = 2 := by omega
    rcases cases with rfl | rfl | rfl <;> decide
  · intro i hi
    have fixed := slots_outside_block_fixed i (by omega)
    exact ⟨fixed, fixed⟩
  · intro i hi
    have cases : i = 0 ∨ i = 1 ∨ i = 2 := by omega
    rcases cases with rfl | rfl | rfl <;> rfl
  · intro i _
    simp [moveFrames, swap.leftInverse]

theorem social_repeated_domain_reads :
    (moveFrames swap socialFrames 2).dependencies = [1, 1] := by rfl

theorem untransported_dependency_rejected :
    ¬ checkedTransport socialFrames socialFrames swap 3 := by
  intro h
  have bad := congrArg Frame.dependencies (h.targetFrame 2 (by decide))
  simp [socialFrames, moveFrame, swap, swap01] at bad

theorem changed_dependency_multiplicity_rejected :
    ¬ checkedTransport socialFrames
      (fun i => if i = 2 then { socialFrames i with dependencies := [1] }
        else moveFrames swap socialFrames i) swap 3 := by
  intro h
  have bad := congrArg Frame.dependencies (h.targetFrame 2 (by decide))
  simp [socialFrames, moveFrame, swap, swap01] at bad

theorem wrong_frame_rejected (frames target : Nat → Frame) (p : Permutation)
    (n i : Nat) (hi : i < n)
    (bad : target (p.forward i) ≠ moveFrame p.forward (frames i)) :
    ¬ checkedTransport frames target p n := fun h => bad (h.targetFrame i hi)

theorem changed_phase_rejected :
    ¬ checkedTransport socialFrames
      (fun i => { moveFrames swap socialFrames i with phase := 1 }) swap 3 := by
  intro h
  have bad := congrArg Frame.phase (h.targetFrame 2 (by decide))
  simp [socialFrames, moveFrame, swap, swap01] at bad

theorem changed_type_rejected :
    ¬ checkedTransport socialFrames
      (fun i => { moveFrames swap socialFrames i with type := 2 }) swap 3 := by
  intro h
  have bad := congrArg Frame.type (h.targetFrame 2 (by decide))
  simp [socialFrames, moveFrame, swap, swap01] at bad

def socialDomain (follows : U → U → Prop) (u f : U) : Prop :=
  (∃ middle, follows u middle ∧ follows middle f) ∧ f ≠ u

def socialBody (follows suggested : U → U → Prop) (u uu f : U) : Prop :=
  (¬ follows u uu ∧ uu = f) → suggested u uu

def socialMeaning (follows suggested : U → U → Prop) (v : U × U × U) : Prop :=
  v.1 ≠ v.2.1 → socialDomain follows v.1 v.2.2 →
    socialBody follows suggested v.1 v.2.1 v.2.2

def swapValues (v : U × U × U) : U × U × U := (v.2.1, v.1, v.2.2)
theorem swap_values_inverse (v : U × U × U) : swapValues (swapValues v) = v := by
  cases v with | mk a rest => cases rest; rfl

theorem social_source_transport (follows suggested : U → U → Prop) :
    (∀ v, socialMeaning follows suggested (swapValues v)) ↔
      ∀ v, socialMeaning follows suggested v :=
  all_transport swapValues swapValues swap_values_inverse (socialMeaning follows suggested)

theorem social_source_syntax (follows suggested : U → U → Prop) :
    (∀ v, socialMeaning follows suggested v) ↔
      ∀ u uu f, u ≠ uu → socialDomain follows u f →
        ((¬ follows u uu ∧ uu = f) → suggested u uu) := by
  constructor
  · intro h u uu f
    exact h (u, uu, f)
  · intro h v
    exact h v.1 v.2.1 v.2.2

theorem social_source_context (follows suggested : U → U → Prop) (rest : Prop) :
    ((∀ v, socialMeaning follows suggested (swapValues v)) ∧ rest) ↔
      ((∀ v, socialMeaning follows suggested v) ∧ rest) :=
  and_congr (social_source_transport follows suggested) Iff.rfl

end DependentBinderTransport
