/-
Abstract Phase 3 model for source-command-bound semantic profiles. This file
proves the fixed-profile counterexamples and the minimum exact-selection
contract only. It does not prove Alloy parsing, scope computation, Java
refinement, hashing, solver correctness, or verifier source binding.
-/

import Std

namespace Phase3SemanticProfile

inductive OverflowMode where
  | modular
  | forbid
deriving DecidableEq, Repr

inductive TemporalMode where
  | staticModel
  | bounded (minimum maximum : Nat)
  | unbounded (minimum : Nat)
deriving DecidableEq, Repr

structure SourceCommand where
  commandLabel : Nat
  commandFormula : Nat
  rawBitwidth : Option Nat
  noOverflow : Bool
  temporal : TemporalMode
  scopes : List Nat
  executionOptions : List Nat
  rewriteVersion : Nat
  signatureVersion : Nat
deriving DecidableEq, Repr

structure Profile where
  commandLabel : Nat
  commandFormula : Nat
  bitwidth : Nat
  overflow : OverflowMode
  temporal : TemporalMode
  scopes : List Nat
  executionOptions : List Nat
  rewriteVersion : Nat
  signatureVersion : Nat
deriving DecidableEq, Repr

def effectiveBitwidth (raw : Option Nat) : Nat := raw.getD 4

def deriveProfile (source : SourceCommand) : Option Profile :=
  let width := effectiveBitwidth source.rawBitwidth
  if 30 < width then
    none
  else
    some {
      commandLabel := source.commandLabel
      commandFormula := source.commandFormula
      bitwidth := width
      overflow := if source.noOverflow then .forbid else .modular
      temporal := source.temporal
      scopes := source.scopes
      executionOptions := source.executionOptions
      rewriteVersion := source.rewriteVersion
      signatureVersion := source.signatureVersion
    }

def fixedProfile (_source : SourceCommand) : Profile := {
  commandLabel := 0
  commandFormula := 0
  bitwidth := 4
  overflow := .forbid
  temporal := .staticModel
  scopes := []
  executionOptions := []
  rewriteVersion := 0
  signatureVersion := 0
}

def source4 : SourceCommand := {
  commandLabel := 11
  commandFormula := 101
  rawBitwidth := some 4
  noOverflow := false
  temporal := .staticModel
  scopes := [3]
  executionOptions := [0]
  rewriteVersion := 3
  signatureVersion := 7
}

def sourceOmitted : SourceCommand := {
  source4 with rawBitwidth := none
}

def sourceZero : SourceCommand := {
  source4 with rawBitwidth := some 0
}

def source5 : SourceCommand := {
  source4 with rawBitwidth := some 5
}

def source4Forbid : SourceCommand := {
  source4 with noOverflow := true
}

def sourceTemporal23 : SourceCommand := {
  source4 with temporal := .bounded 2 3
}

def sourceTemporal25 : SourceCommand := {
  source4 with temporal := .bounded 2 5
}

def sourceScope5 : SourceCommand := {
  source4 with scopes := [5]
}

def sourceExecution1 : SourceCommand := {
  source4 with executionOptions := [1]
}

def sourceRewrite4 : SourceCommand := {
  source4 with rewriteVersion := 4
}

def sourceSignature8 : SourceCommand := {
  source4 with signatureVersion := 8
}

def sourceFormula102 : SourceCommand := {
  source4 with commandFormula := 102
}

def sourceLabel12 : SourceCommand := {
  source4 with commandLabel := 12
}

theorem fixed_selector_aliases_width_4_and_5 :
    fixedProfile source4 = fixedProfile source5 := by
  rfl

theorem fixed_selector_aliases_overflow_modes :
    fixedProfile source4 = fixedProfile source4Forbid := by
  rfl

theorem fixed_selector_aliases_temporal_bounds :
    fixedProfile sourceTemporal23 = fixedProfile sourceTemporal25 := by
  rfl

theorem exact_selector_separates_width_4_and_5 :
    deriveProfile source4 ≠ deriveProfile source5 := by
  decide

theorem omitted_width_defaults_to_four :
    (deriveProfile sourceOmitted).map Profile.bitwidth = some 4 := by
  decide

theorem explicit_zero_width_is_preserved :
    (deriveProfile sourceZero).map Profile.bitwidth = some 0 := by
  decide

theorem exact_selector_separates_overflow_modes :
    deriveProfile source4 ≠ deriveProfile source4Forbid := by
  decide

theorem exact_selector_separates_temporal_bounds :
    deriveProfile sourceTemporal23 ≠ deriveProfile sourceTemporal25 := by
  decide

theorem exact_selector_separates_scope_contexts :
    deriveProfile source4 ≠ deriveProfile sourceScope5 := by
  decide

theorem exact_selector_separates_execution_options :
    deriveProfile source4 ≠ deriveProfile sourceExecution1 := by
  decide

theorem exact_selector_separates_rewrite_versions :
    deriveProfile source4 ≠ deriveProfile sourceRewrite4 := by
  decide

theorem exact_selector_separates_signature_versions :
    deriveProfile source4 ≠ deriveProfile sourceSignature8 := by
  decide

theorem exact_selector_separates_command_formulae :
    deriveProfile source4 ≠ deriveProfile sourceFormula102 := by
  decide

theorem exact_selector_separates_command_labels :
    deriveProfile source4 ≠ deriveProfile sourceLabel12 := by
  decide

def deriveFromUniqueSelection
    (commands : List SourceCommand) : Option Profile :=
  match commands with
  | [source] => deriveProfile source
  | _ => none

theorem missing_selection_rejects :
    deriveFromUniqueSelection [] = none := by
  rfl

theorem ambiguous_selection_rejects :
    deriveFromUniqueSelection [source4, source5] = none := by
  rfl

structure ParserSelection where
  command : SourceCommand
  ownedByParsedModule : Bool
deriving DecidableEq, Repr

def deriveFromParserSelection
    (selected : List ParserSelection) : Option Profile :=
  match selected with
  | [selection] =>
      if selection.ownedByParsedModule then deriveProfile selection.command
      else none
  | _ => none

theorem parser_owned_unique_selection_derives :
    deriveFromParserSelection [⟨source4, true⟩] = deriveProfile source4 := by
  rfl

theorem foreign_command_selection_rejects :
    deriveFromParserSelection [⟨source4, false⟩] = none := by
  rfl

inductive ProfileAuthority where
  | callerAssertion
  | fixedCompatibility
  | parsedSourceCommand
deriving DecidableEq, Repr

def productionAuthorized : ProfileAuthority -> Bool
  | .parsedSourceCommand => true
  | _ => false

theorem caller_asserted_profile_is_not_authorized :
    productionAuthorized .callerAssertion = false := by
  rfl

theorem parser_owned_profile_is_authorized :
    productionAuthorized .parsedSourceCommand = true := by
  rfl

def exportAuthorized
    (authority : ProfileAuthority)
    (testOnly : Bool) : Bool :=
  productionAuthorized authority
    || (authority == .fixedCompatibility && testOnly)

theorem fixed_compatibility_cannot_authorize_publication :
    exportAuthorized .fixedCompatibility false = false := by
  rfl

theorem fixed_compatibility_can_authorize_test_only :
    exportAuthorized .fixedCompatibility true = true := by
  rfl

def comparable (left right : Profile) : Bool := left == right

theorem cross_profile_comparison_rejects
    {left right : Profile}
    (different : left ≠ right) :
    comparable left right = false := by
  simp [comparable, different]

structure PreparedObservation where
  profile : Profile
  observation : Nat
  retainsConstructionEvidence : Bool
deriving DecidableEq, Repr

def compact (source : PreparedObservation) : PreparedObservation := {
  source with retainsConstructionEvidence := false
}

theorem compact_preserves_profile (source : PreparedObservation) :
    (compact source).profile = source.profile := by
  rfl

def comparePrepared
    (left right : PreparedObservation) : Option Bool :=
  if left.profile = right.profile then
    some (left.observation == right.observation)
  else
    none

theorem compact_cross_profile_comparison_rejects
    {left right : PreparedObservation}
    (different : left.profile ≠ right.profile) :
    comparePrepared (compact left) (compact right) = none := by
  simp [comparePrepared, compact, different]

theorem source_bound_verification_is_exact
    {expected emitted : Profile}
    (accepted : some expected = some emitted) :
    expected = emitted := by
  exact Option.some.inj accepted

end Phase3SemanticProfile
