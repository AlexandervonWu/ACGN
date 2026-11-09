import Std

/- Composition boundary only. Replay is the existing fixed-choice verifier;
   this does not prove that Java replay implements the model. -/
namespace CapturedSelectionAuthority
def Authorized (selection : Option S) (receipt : R) (replay : S → R → Prop) : Prop :=
  ∃ s, selection = some s ∧ replay s receipt

def Accepted (fast : Option F) (certified : Option C) (fr : FR) (cr : CR)
    (replayFast : F → FR → Prop) (replayCertified : C → CR → Prop)
    (downstream : Prop) : Prop :=
  Authorized fast fr replayFast ∧ Authorized certified cr replayCertified ∧ downstream

theorem both_authorities_required
    (h : Accepted f c fr cr rf rc downstream) :
    Authorized f fr rf ∧ Authorized c cr rc := ⟨h.1, h.2.1⟩

theorem missing_fast_rejected : ¬ Accepted (none : Option F) c fr cr rf rc downstream := by
  rintro ⟨⟨s, h, _⟩, _⟩
  cases h

theorem missing_certified_rejected : ¬ Accepted f (none : Option C) fr cr rf rc downstream := by
  rintro ⟨_, ⟨s, h, _⟩, _⟩
  cases h

theorem foreign_fast_rejected (failed : ¬ rf s fr) :
    ¬ Accepted (some s) c fr cr rf rc downstream := by
  rintro ⟨⟨other, equal, replay⟩, _⟩
  cases Option.some.inj equal
  exact failed replay

theorem foreign_certified_rejected (failed : ¬ rc s cr) :
    ¬ Accepted f (some s) fr cr rf rc downstream := by
  rintro ⟨_, ⟨other, equal, replay⟩, _⟩
  cases Option.some.inj equal
  exact failed replay

theorem valid_selection_preserves_downstream
    (hf : Authorized f fr rf) (hc : Authorized c cr rc) :
    Accepted f c fr cr rf rc downstream ↔ downstream :=
  ⟨fun h => h.2.2, fun h => ⟨hf, hc, h⟩⟩

#print axioms both_authorities_required
#print axioms missing_fast_rejected
#print axioms missing_certified_rejected
#print axioms foreign_fast_rejected
#print axioms foreign_certified_rejected
#print axioms valid_selection_preserves_downstream
end CapturedSelectionAuthority
