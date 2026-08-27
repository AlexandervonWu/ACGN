/-
  Independent finite model of the standalone verifier trust boundary.
-/

namespace Section3.TrustBoundary

inductive Outcome where
  | verified
  | uncheckable
  | rejected
  deriving DecidableEq, Repr

inductive Authority where
  | testOnly
  | testOnlyInputSpecific
  | production
  deriving DecidableEq, Repr

inductive Mode where
  | testOnly
  | publication
  deriving DecidableEq, Repr

structure Pin where
  digest : Nat
  authority : Authority
  admittedInput : Option Nat
  admittedGroundEquation : Option (Nat × Nat)
  deriving DecidableEq, Repr

structure BundleClaim where
  claimedDigest : Nat
  input : Nat
  mode : Mode
  dirty : Bool
  suppliedGroundEquation : Option (Nat × Nat)
  deriving DecidableEq, Repr

inductive EvidenceState where
  | completeAndValid
  | missingOrResourceCapped
  | malformedOrFalse
  deriving DecidableEq, Repr

def authorityAdmits (pin : Pin) (bundle : BundleClaim) : Bool :=
  match pin.authority, bundle.mode with
  | .production, .publication => true
  | .production, .testOnly => true
  | .testOnly, .testOnly => true
  | .testOnlyInputSpecific, .testOnly => pin.admittedInput == some bundle.input
  | _, _ => false

def equationAdmitted (pin : Pin) (bundle : BundleClaim) : Bool :=
  bundle.suppliedGroundEquation == pin.admittedGroundEquation

def verify
    (externalPin : Option Pin)
    (bundle : BundleClaim)
    (evidence : EvidenceState) : Outcome :=
  match externalPin with
  | none => .uncheckable
  | some pin =>
      if bundle.claimedDigest != pin.digest then .rejected
      else if !authorityAdmits pin bundle then .rejected
      else if bundle.mode == .publication && bundle.dirty then .rejected
      else if !equationAdmitted pin bundle then .rejected
      else match evidence with
        | .completeAndValid => .verified
        | .missingOrResourceCapped => .uncheckable
        | .malformedOrFalse => .rejected

theorem bundle_selected_digest_is_not_authority
    (bundle : BundleClaim)
    (evidence : EvidenceState) :
    verify none bundle evidence = .uncheckable := by
  rfl

theorem digest_disagreement_rejects
    (pin : Pin)
    (bundle : BundleClaim)
    (different : bundle.claimedDigest != pin.digest)
    (evidence : EvidenceState) :
    verify (some pin) bundle evidence = .rejected := by
  simp [verify, different]

theorem dirty_publication_rejects
    (pin : Pin)
    (bundle : BundleClaim)
    (digest : bundle.claimedDigest = pin.digest)
    (authority : authorityAdmits pin bundle = true)
    (publication : bundle.mode = .publication)
    (dirty : bundle.dirty = true) :
    verify (some pin) bundle .completeAndValid = .rejected := by
  simp [verify, digest, authority, publication, dirty]

theorem missing_evidence_or_resource_cap_is_uncheckable
    (pin : Pin)
    (bundle : BundleClaim)
    (digest : bundle.claimedDigest = pin.digest)
    (authority : authorityAdmits pin bundle = true)
    (clean : Not (bundle.mode = .publication /\ bundle.dirty = true))
    (equation : equationAdmitted pin bundle = true) :
    verify (some pin) bundle .missingOrResourceCapped = .uncheckable := by
  cases mode : bundle.mode <;> cases dirt : bundle.dirty <;>
    simp_all [verify]

theorem malformed_or_false_evidence_rejects
    (pin : Pin)
    (bundle : BundleClaim)
    (digest : bundle.claimedDigest = pin.digest)
    (authority : authorityAdmits pin bundle = true)
    (clean : Not (bundle.mode = .publication /\ bundle.dirty = true))
    (equation : equationAdmitted pin bundle = true) :
    verify (some pin) bundle .malformedOrFalse = .rejected := by
  cases mode : bundle.mode <;> cases dirt : bundle.dirty <;>
    simp_all [verify]

def fixtureEmptyPin : Pin := {
  digest := 9
  authority := .testOnly
  admittedInput := none
  admittedGroundEquation := none
}

def fixtureParentPin : Pin := {
  digest := 90
  authority := .testOnlyInputSpecific
  admittedInput := some 13
  admittedGroundEquation := some (2, 1)
}

def parentFixture : BundleClaim := {
  claimedDigest := 90
  input := 13
  mode := .testOnly
  dirty := false
  suppliedGroundEquation := some (2, 1)
}

theorem declared_parent_fixture_is_admitted :
    verify (some fixtureParentPin) parentFixture .completeAndValid = .verified := by
  native_decide

theorem parent_pin_cannot_authorize_another_input :
    verify (some fixtureParentPin)
      { parentFixture with input := 14 }
      .completeAndValid = .rejected := by
  native_decide

theorem parent_pin_cannot_authorize_another_ground_equation :
    verify (some fixtureParentPin)
      { parentFixture with suppliedGroundEquation := some (3, 1) }
      .completeAndValid = .rejected := by
  native_decide

theorem parent_pin_cannot_authorize_publication :
    verify (some fixtureParentPin)
      { parentFixture with mode := .publication }
      .completeAndValid = .rejected := by
  native_decide

theorem empty_fixture_pin_authorizes_no_ground_equation :
    verify (some fixtureEmptyPin)
      { claimedDigest := 9
        input := 1
        mode := .testOnly
        dirty := false
        suppliedGroundEquation := some (1, 1) }
      .completeAndValid = .rejected := by
  native_decide

end Section3.TrustBoundary
