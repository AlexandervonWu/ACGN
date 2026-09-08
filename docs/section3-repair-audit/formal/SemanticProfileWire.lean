import Std

namespace ACGN.FourthFive.SemanticProfileWire

-- Unicode scalar sequences avoid repeated UTF-8 packing during kernel replay.
abbrev Text := List Char

def ofCodepoints (values : List Nat) : Text := values.map Char.ofNat

-- Scalars retain exact wire texts, including the canonical decimal bitwidth.
structure Profile where
  bitwidth : Text
  overflow : Text
  temporal : Text
  rewrite : Text
  signature : Text
  deriving DecidableEq, BEq

def fields (p : Profile) : List Text :=
  [p.bitwidth, p.overflow, p.temporal, p.rewrite, p.signature]

def reconstruct : List Text -> Option Profile
  | [b, o, t, r, s] => some ⟨b, o, t, r, s⟩
  | _ => none

-- Java String.length counts supplementary scalar values as two UTF-16 units.
-- Lean Strings contain Unicode scalar values; isolated Java surrogates are
-- excluded here and rejected by the production certificate UTF-8 codec.
def utf16Length (s : Text) : Nat :=
  (s.map fun c => if c.toNat < 65536 then 1 else 2).sum

def frame (s : Text) : Text := (toString (utf16Length s)).toList ++ [':'] ++ s

def encode (p : Profile) : Text :=
  "16:semantic-profile[5:".toList ++ frame p.bitwidth ++ frame p.overflow ++
    frame p.temporal ++ frame p.rewrite ++ frame p.signature ++ "]{0:}".toList

def encodedString (p : Profile) : String := String.ofList (encode p)

theorem encoded_string_roundtrip (p : Profile) : (encodedString p).toList = encode p := by
  simp [encodedString]

-- Independent list-based reconstruction, not a call to the producer encoder.
def verifierEncoding (xs : List Text) : Option Text :=
  match xs with
  | [b, o, t, r, s] => some (frame "semantic-profile".toList ++ "[5:".toList ++
      frame b ++ frame o ++ frame t ++ frame r ++ frame s ++ "]{0:}".toList)
  | _ => none

def exact (p : Profile) (xs : List Text) : Bool := decide (reconstruct xs = some p)

inductive Authority where
  | custom | compatibility | source
  deriving DecidableEq, BEq

def exportAllowed (a : Authority) (testOnly : Bool) : Bool :=
  a == .source || (testOnly && a == .compatibility)

def contextVersion : Text := "alloy-command-options-v4-independent-search-domain".toList

def contextVersionAllowed (version : Text) : Bool := decide (version = contextVersion)

theorem context_version_iff (version : Text) :
    contextVersionAllowed version = true ↔ version = contextVersion := by
  simp [contextVersionAllowed]

theorem context_version_current : contextVersionAllowed contextVersion = true := by
  simp [contextVersionAllowed]

theorem context_version_reject (version : Text) (h : version ≠ contextVersion) :
    contextVersionAllowed version = false := by
  simp [contextVersionAllowed, h]

theorem reconstruct_fields (p : Profile) : reconstruct (fields p) = some p := by
  cases p
  rfl

theorem reconstruct_some_iff (xs : List Text) (p : Profile) :
    reconstruct xs = some p ↔ xs = fields p := by
  cases xs with
  | nil => simp [reconstruct, fields]
  | cons b xs => cases xs with
    | nil => simp [reconstruct, fields]
    | cons o xs => cases xs with
      | nil => simp [reconstruct, fields]
      | cons t xs => cases xs with
        | nil => simp [reconstruct, fields]
        | cons r xs => cases xs with
          | nil => simp [reconstruct, fields]
          | cons s xs => cases xs with
            | nil => cases p; simp [reconstruct, fields, Profile.mk.injEq]
            | cons x xs => simp [reconstruct, fields]

theorem five_fields (p : Profile) : (fields p).length = 5 := rfl

theorem fields_injective (p q : Profile) : fields p = fields q ↔ p = q := by
  cases p; cases q
  simp [fields, Profile.mk.injEq]

theorem exact_iff (p : Profile) (xs : List Text) :
    exact p xs = true ↔ xs = fields p := by
  simp [exact, reconstruct_some_iff]

theorem all_field_mutations_rejected (p q : Profile) (h : p ≠ q) :
    exact p (fields q) = false := by
  simp [exact, reconstruct_fields, Ne.symm h]

theorem encoding_agreement (p : Profile) :
    verifierEncoding (fields p) = some (encode p) := by
  rfl

theorem reconstructed_encoding (xs : List Text) (p : Profile)
    (h : reconstruct xs = some p) : verifierEncoding xs = some (encode p) := by
  rw [(reconstruct_some_iff xs p).mp h]
  exact encoding_agreement p

theorem frame_preserves_text (s : Text) :
    frame s = (toString (utf16Length s)).toList ++ [':'] ++ s := rfl

theorem custom_never_exports (testOnly : Bool) :
    exportAllowed .custom testOnly = false := by cases testOnly <;> rfl

theorem compatibility_not_publication : exportAllowed .compatibility false = false := rfl

theorem source_exports (testOnly : Bool) :
    exportAllowed .source testOnly = true := by cases testOnly <;> rfl

-- A digest is only a deterministic function here. No injectivity assumption.
theorem equal_payload_equal_digest (digest : String -> String) (p q : Profile)
    (h : fields p = fields q) : digest (encodedString p) = digest (encodedString q) := by
  rw [(fields_injective p q).mp h]

#print axioms encoded_string_roundtrip
#print axioms context_version_iff
#print axioms context_version_current
#print axioms context_version_reject
#print axioms reconstruct_fields
#print axioms reconstruct_some_iff
#print axioms five_fields
#print axioms fields_injective
#print axioms exact_iff
#print axioms all_field_mutations_rejected
#print axioms encoding_agreement
#print axioms reconstructed_encoding
#print axioms frame_preserves_text
#print axioms custom_never_exports
#print axioms compatibility_not_publication
#print axioms source_exports
#print axioms equal_payload_equal_digest

end ACGN.FourthFive.SemanticProfileWire
