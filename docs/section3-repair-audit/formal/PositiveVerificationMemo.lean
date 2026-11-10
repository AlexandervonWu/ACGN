/- A positive memo reuses only completed verification of the same identity and
   policy. Identity allocation, Java immutability and scope ownership remain
   implementation correspondence obligations, not claims proved by this model. -/
namespace ACGN.PositiveVerificationMemo

variable {Identity Policy : Type} [DecidableEq Identity] [DecidableEq Policy]

def Sound (verify : Identity × Policy → Bool) (memo : List (Identity × Policy)) : Prop :=
  ∀ key ∈ memo, verify key = true

def check (verify : Identity × Policy → Bool) (memo : List (Identity × Policy))
    (key : Identity × Policy) : Bool :=
  if key ∈ memo then true else verify key

omit [DecidableEq Identity] [DecidableEq Policy] in
theorem empty_sound (verify : Identity × Policy → Bool) : Sound verify [] := by
  simp [Sound]

omit [DecidableEq Identity] [DecidableEq Policy] in
theorem successful_insert (verify : Identity × Policy → Bool)
    (memo : List (Identity × Policy)) (key : Identity × Policy)
    (old : Sound verify memo) (completed : verify key = true) :
    Sound verify (key :: memo) := by
  intro x hx
  simp only [List.mem_cons] at hx
  rcases hx with same | prior
  · simpa [same] using completed
  · exact old x prior

theorem check_eq_verification (verify : Identity × Policy → Bool)
    (memo : List (Identity × Policy)) (key : Identity × Policy)
    (sound : Sound verify memo) : check verify memo key = verify key := by
  unfold check
  split
  · exact (sound key ‹key ∈ memo›).symm
  · rfl

omit [DecidableEq Identity] [DecidableEq Policy] in
theorem discard_sound (verify : Identity × Policy → Bool)
    (memo retained : List (Identity × Policy)) (sound : Sound verify memo)
    (subset : ∀ key ∈ retained, key ∈ memo) : Sound verify retained := by
  intro key member
  exact sound key (subset key member)

#print axioms successful_insert
#print axioms check_eq_verification
#print axioms discard_sound
end ACGN.PositiveVerificationMemo
