import Std

namespace ACGN.FifthFive.Source

abbrev Text := List Char
def ofCodepoints (xs : List Nat) : Text := xs.map Char.ofNat

structure Path where
  phase : Nat
  children : List Nat
  deriving DecidableEq, BEq

def rootPath (phase : Nat) : Path := ⟨phase, []⟩
def childPath (path : Path) (index : Nat) : Path :=
  ⟨path.phase, path.children ++ [index]⟩

def renderPath (path : Path) : Text :=
  ("phase/" ++ toString path.phase ++ "/matrix").toList ++
    (path.children.flatMap fun i => ("/child/" ++ toString i).toList)

-- Ids model object identity, not semantic equality or JVM allocation numbers.
inductive Tree where
  | node (identity : Nat) (children : List Tree)

mutual
def walk (path : Path) : Tree -> List (Nat × Path)
  | .node identity children => (identity, path) ::
      walkChildren path 0 children
termination_by tree => sizeOf tree

def walkChildren (path : Path) (start : Nat) : List Tree -> List (Nat × Path)
  | [] => []
  | tree :: rest => walk (childPath path start) tree ++ walkChildren path (start + 1) rest
termination_by trees => sizeOf trees
end

def traverse (phases : List (Option Tree)) : List (Nat × Path) :=
  phases.zipIdx.flatMap fun (tree, phase) =>
    match tree with
    | none => []
    | some tree => walk (rootPath phase) tree

def admitOccurrences (entries : List (Nat × Path)) : Option (List (Nat × Path)) :=
  if (entries.map Prod.fst).Nodup then some entries else none

def index (phases : List (Option Tree)) : Option (List (Nat × Path)) :=
  admitOccurrences (traverse phases)

theorem child_phase (p : Path) (i : Nat) : (childPath p i).phase = p.phase := rfl
theorem child_indices (p : Path) (i : Nat) :
    (childPath p i).children = p.children ++ [i] := rfl
theorem child_injective (p q : Path) (i j : Nat) :
    childPath p i = childPath q j ↔ p = q ∧ i = j := by
  cases p; cases q
  simp [childPath, Path.mk.injEq, and_assoc]

theorem walk_root (p : Path) (id : Nat) (cs : List Tree) :
    (id, p) ∈ walk p (.node id cs) := by
  simp [walk]

theorem walk_children (p : Path) (id : Nat) (cs : List Tree) :
    (walk p (.node id cs)).tail =
      walkChildren p 0 cs := by rw [walk]; rfl

theorem admit_iff (entries out : List (Nat × Path)) :
    admitOccurrences entries = some out ↔ entries = out ∧ (entries.map Prod.fst).Nodup := by
  simp only [admitOccurrences]
  split <;> simp_all

theorem index_exact (phases : List (Option Tree)) (out : List (Nat × Path)) :
    index phases = some out ↔ traverse phases = out ∧
      ((traverse phases).map Prod.fst).Nodup := admit_iff _ _

theorem duplicate_ownership_rejected (entries : List (Nat × Path))
    (h : ¬ (entries.map Prod.fst).Nodup) : admitOccurrences entries = none := by
  simp [admitOccurrences, h]

theorem admitted_unique (entries out : List (Nat × Path))
    (h : admitOccurrences entries = some out) : (out.map Prod.fst).Nodup := by
  obtain ⟨rfl, hn⟩ := (admit_iff _ _).mp h
  exact hn

def utf16Length (s : Text) : Nat :=
  (s.map fun c => if c.toNat < 65536 then 1 else 2).sum
def frame (s : Text) : Text := (toString (utf16Length s)).toList ++ [':'] ++ s

-- Leaf keys are the supplied sortKey boundary. Application structure is exact,
-- including association, opcode, profile, exact type and ordered slot maps.
inductive Content where
  | leaf (sortKey : Text)
  | app (opcode profile exactType leftSlots : Text) (left : Content)
      (rightSlots : Text) (right : Content)
  deriving DecidableEq

def encodeContent : Content -> Text
  | .leaf key => frame "leaf".toList ++ frame key
  | .app op profile ty ls l rs r =>
      frame "application".toList ++ frame op ++ frame profile ++ frame ty ++
        frame ls ++ encodeContent l ++ frame rs ++ encodeContent r

-- This grammar traversal does not assert injectivity of arbitrary leaf keys.
def contentTokens : Content -> List Text
  | .leaf key => ["leaf".toList, key]
  | .app op profile ty ls l rs r =>
      ["application".toList, op, profile, ty, ls] ++ contentTokens l ++ [rs] ++ contentTokens r

theorem content_encoding_grammar (c : Content) :
    encodeContent c = (contentTokens c).flatMap frame := by
  induction c with
  | leaf key => simp [encodeContent, contentTokens]
  | app op profile ty ls l rs r hl hr =>
    simp [encodeContent, contentTokens, hl, hr, List.flatMap_append, List.append_assoc]

theorem leaf_structural (x y : Text) : Content.leaf x = .leaf y ↔ x = y := by
  simp
theorem application_structural (op p ty ls rs op' p' ty' ls' rs' : Text)
    (l r l' r' : Content) :
    Content.app op p ty ls l rs r = .app op' p' ty' ls' l' rs' r' ↔
      op = op' ∧ p = p' ∧ ty = ty' ∧ ls = ls' ∧ l = l' ∧ rs = rs' ∧ r = r' := by
  simp
theorem association_retained (op p ty slots a b c : Text) :
    Content.app op p ty slots (.app op p ty slots (.leaf a) slots (.leaf b)) slots (.leaf c) ≠
      .app op p ty slots (.leaf a) slots (.app op p ty slots (.leaf b) slots (.leaf c)) := by
  simp

structure Commitment where
  path : Path
  typedSource : Text
  content : Content
  deriving DecidableEq

-- typedSource is the already-encoded supplied StructuralKey, not a digest.
def branch (tag : Text) (children : List Text) : Text :=
  frame tag ++ "[0:]{".toList ++ (toString children.length).toList ++ [':'] ++
    children.flatMap frame ++ "}".toList
def scalarKey (tag scalar : Text) : Text :=
  frame tag ++ "[1:".toList ++ frame scalar ++ "]{0:}".toList
def encodeKey (tag : Text) (scalars children : List Text) : Text :=
  frame tag ++ "[".toList ++ (toString scalars.length).toList ++ [':'] ++
    scalars.flatMap frame ++ "]{".toList ++ (toString children.length).toList ++ [':'] ++
    children.flatMap frame ++ "}".toList
def encodeCommitment (c : Commitment) : Text :=
  frame "alloy-dependent-chain-source-occurrence-v1".toList ++ "[1:".toList ++
    frame (renderPath c.path) ++ "]{2:".toList ++
    frame (branch "alloy-dependent-chain-typed-source-v1".toList [c.typedSource]) ++
    frame (scalarKey "alloy-dependent-chain-source-content-v1".toList (encodeContent c.content)) ++
    "}".toList

theorem commitment_encoding_grammar (c : Commitment) :
    encodeCommitment c = encodeKey "alloy-dependent-chain-source-occurrence-v1".toList
      [renderPath c.path]
      [encodeKey "alloy-dependent-chain-typed-source-v1".toList [] [c.typedSource],
       encodeKey "alloy-dependent-chain-source-content-v1".toList [encodeContent c.content] []] := by
  simp [encodeCommitment, encodeKey, branch, scalarKey, List.append_assoc]
  rfl

theorem commitment_structural (p q : Path) (t u : Text) (c d : Content) :
    Commitment.mk p t c = ⟨q, u, d⟩ ↔ p = q ∧ t = u ∧ c = d := by
  simp

structure Binding where
  lineage : Nat
  certified : Commitment
  repair : Commitment
  transfer : Text
  deriving DecidableEq

def checkMatches (b : Binding) (lineage : Nat) (current : Commitment) (transfer : Text) : Bool :=
  decide (lineage = b.lineage ∧ current = b.repair ∧ transfer = b.transfer)

def transferTo (b : Binding) (lineage : Nat) (current : Commitment) (transfer : Text) :
    Option Binding :=
  if lineage = b.lineage ∧ transfer = b.transfer ∧ current.path = b.certified.path ∧
      current.typedSource = b.certified.typedSource then
    some { b with repair := current }
  else none

theorem matches_iff (b : Binding) (n : Nat) (c : Commitment) (t : Text) :
    checkMatches b n c t = true ↔ n = b.lineage ∧ c = b.repair ∧ t = b.transfer := by
  simp [checkMatches]
theorem wrong_lineage_rejected (b : Binding) (n : Nat) (c : Commitment) (t : Text)
    (h : n ≠ b.lineage) : checkMatches b n c t = false := by
  simp [checkMatches, h]
theorem changed_content_rejected (b : Binding) (n : Nat) (c : Commitment) (t : Text)
    (h : c ≠ b.repair) : checkMatches b n c t = false := by
  simp [checkMatches, h]
theorem changed_transfer_rejected (b : Binding) (n : Nat) (c : Commitment) (t : Text)
    (h : t ≠ b.transfer) : checkMatches b n c t = false := by
  simp [checkMatches, h]
theorem transfer_preserves_source (b out : Binding) (n : Nat) (c : Commitment) (t : Text)
    (h : transferTo b n c t = some out) : out.certified = b.certified ∧ out.lineage = b.lineage := by
  simp only [transferTo] at h
  split at h
  · cases Option.some.inj h
    exact ⟨rfl, rfl⟩
  · contradiction
theorem transfer_matches (b out : Binding) (n : Nat) (c : Commitment) (t : Text)
    (h : transferTo b n c t = some out) : checkMatches out n c t = true := by
  simp only [transferTo] at h
  split at h
  · cases Option.some.inj h
    simp_all [checkMatches]
  · contradiction

#print axioms child_phase
#print axioms child_indices
#print axioms child_injective
#print axioms walk_root
#print axioms walk_children
#print axioms admit_iff
#print axioms index_exact
#print axioms duplicate_ownership_rejected
#print axioms admitted_unique
#print axioms leaf_structural
#print axioms content_encoding_grammar
#print axioms application_structural
#print axioms association_retained
#print axioms commitment_structural
#print axioms commitment_encoding_grammar
#print axioms matches_iff
#print axioms wrong_lineage_rejected
#print axioms changed_content_rejected
#print axioms changed_transfer_rejected
#print axioms transfer_preserves_source
#print axioms transfer_matches

end ACGN.FifthFive.Source
