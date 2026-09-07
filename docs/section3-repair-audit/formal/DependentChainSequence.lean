import Std

/-!
A2-01/A2-02: sequence projection of admitted finite dependent source trees.
Leaf identities stand for complete OnePort identities, not merely their types.
This model does not validate types, JOIN guards, parser authority, Java heaps,
wire parsing, or hashes. See next-five/chain-notes.md for correspondence/TCB.
-/
namespace ACGN.Section3.DependentChainSequence

inductive ChainKind where
  | join | arrow
  deriving DecidableEq

-- Different-head subexpressions are opaque leaf identities, never child apps.
inductive SourceTree (α : Type) : ChainKind → Type where
  | leaf {kind : ChainKind} (value : α) : SourceTree α kind
  | app (kind : ChainKind) (left right : SourceTree α kind) : SourceTree α kind
  deriving DecidableEq

def sourceLeaves : SourceTree α k → List α
  | .leaf a => [a]
  | .app _ l r => sourceLeaves l ++ sourceLeaves r

def leafCount : SourceTree α k → Nat
  | .leaf _ => 1
  | .app _ l r => leafCount l + leafCount r

def occurrenceCount [DecidableEq α] (a : α) : SourceTree α k → Nat
  | .leaf b => if b = a then 1 else 0
  | .app _ l r => occurrenceCount a l + occurrenceCount a r

-- Projection of the producer's left-then-right append-to-output traversal.
def collect (t : SourceTree α k) (acc : List α) : List α :=
  match t with
  | .leaf a => acc ++ [a]
  | .app _ l r => collect r (collect l acc)

-- Projection of the independent replay's fresh-left-list then addAll(right).
def replayLeaves : SourceTree α k → List α
  | .leaf a => [a]
  | .app _ l r => replayLeaves l ++ replayLeaves r

inductive Carrier where
  | seq | bag | set
  deriving DecidableEq

structure Target (α : Type) where
  carrier : Carrier
  elements : List α
  deriving DecidableEq

def construct (t : SourceTree α k) : Target α := ⟨.seq, collect t []⟩

-- Only the carrier/length/positional equality projection of the real verifier.
-- Real replay has additional typing, context, source and certificate checks.
def accepts [DecidableEq α] (t : SourceTree α k) (target : Target α) : Bool :=
  decide (target.carrier = .seq) &&
    decide (target.elements.length = (replayLeaves t).length) &&
    decide (target.elements = replayLeaves t)

theorem collect_prefix (t : SourceTree α k) (acc : List α) :
    collect t acc = acc ++ sourceLeaves t := by
  induction t generalizing acc with
  | leaf a => rfl
  | app l r hl hr => simp [collect, sourceLeaves, hl, hr, List.append_assoc]

theorem construction_preserves_source_sequence (t : SourceTree α k) :
    (construct t).elements = sourceLeaves t := by
  simp [construct, collect_prefix]

theorem replay_preserves_source_sequence (t : SourceTree α k) :
    replayLeaves t = sourceLeaves t := by
  induction t with
  | leaf a => rfl
  | app l r hl hr => simp [replayLeaves, sourceLeaves, hl, hr]

theorem construction_replay_correspondence (t : SourceTree α k) :
    (construct t).elements = replayLeaves t := by
  rw [construction_preserves_source_sequence, replay_preserves_source_sequence]

theorem source_length (t : SourceTree α k) :
    (sourceLeaves t).length = leafCount t := by
  induction t with
  | leaf a => rfl
  | app l r hl hr => simp [sourceLeaves, leafCount, hl, hr]

theorem source_occurrences [DecidableEq α] (t : SourceTree α k) (a : α) :
    (sourceLeaves t).count a = occurrenceCount a t := by
  induction t with
  | leaf b => by_cases h : b = a <;> simp [sourceLeaves, occurrenceCount, h]
  | app l r hl hr => simp [sourceLeaves, occurrenceCount, List.count_append, hl, hr]

theorem construction_preserves_length (t : SourceTree α k) :
    (construct t).elements.length = leafCount t := by
  rw [construction_preserves_source_sequence, source_length]

theorem construction_preserves_occurrences [DecidableEq α] (t : SourceTree α k) (a : α) :
    (construct t).elements.count a = occurrenceCount a t := by
  rw [construction_preserves_source_sequence, source_occurrences]

theorem construction_is_seq (t : SourceTree α k) : (construct t).carrier = .seq := rfl

theorem construction_never_bag_or_set (t : SourceTree α k) :
    (construct t).carrier ≠ .bag ∧ (construct t).carrier ≠ .set := by
  simp [construct]

theorem accepted_iff_source_sequence [DecidableEq α] (t : SourceTree α k) (target : Target α) :
    accepts t target = true ↔
      target.carrier = .seq ∧ target.elements = sourceLeaves t := by
  simp only [accepts, Bool.and_eq_true, decide_eq_true_eq, replay_preserves_source_sequence]
  constructor
  · intro h; exact ⟨h.1.1, h.2⟩
  · intro h; exact ⟨⟨h.1, congrArg List.length h.2⟩, h.2⟩

theorem constructed_target_replays [DecidableEq α] (t : SourceTree α k) :
    accepts t (construct t) = true := by
  rw [accepted_iff_source_sequence]
  exact ⟨construction_is_seq t, construction_preserves_source_sequence t⟩

theorem accepted_preserves_length_and_count [DecidableEq α]
    (t : SourceTree α k) (target : Target α) (a : α) (h : accepts t target = true) :
    target.elements.length = leafCount t ∧ target.elements.count a = occurrenceCount a t := by
  rw [(accepted_iff_source_sequence t target).mp h |>.2]
  exact ⟨source_length t, source_occurrences t a⟩

theorem changed_sequence_rejects [DecidableEq α] (t : SourceTree α k) (target : Target α)
    (h : target.elements ≠ sourceLeaves t) : accepts t target = false := by
  cases e : accepts t target with
  | false => rfl
  | true => exact False.elim (h ((accepted_iff_source_sequence t target).mp e).2)

theorem reassociation_preserves_sequence (k : ChainKind) (l m r : SourceTree α k) :
    (construct (.app k (.app k l m) r)).elements =
      (construct (.app k l (.app k m r))).elements := by
  simp [construction_preserves_source_sequence, sourceLeaves, List.append_assoc]

theorem distinct_order_is_observable (k : ChainKind) (a b : α) (h : a ≠ b) :
    (construct (.app k (.leaf a) (.leaf b))).elements ≠
      (construct (.app k (.leaf b) (.leaf a))).elements := by
  simp [construction_preserves_source_sequence, sourceLeaves, h]

theorem duplicate_is_retained (k : ChainKind) (a : α) :
    (construct (.app k (.leaf a) (.leaf a))).elements = [a, a] := by
  simp [construction_preserves_source_sequence, sourceLeaves]

theorem duplicate_deletion_rejects [DecidableEq α] (k : ChainKind) (a : α) :
    accepts (.app k (.leaf a) (.leaf a)) ⟨.seq, [a]⟩ = false := by
  simp [accepts, replayLeaves]

#print axioms collect_prefix
#print axioms construction_preserves_source_sequence
#print axioms replay_preserves_source_sequence
#print axioms construction_replay_correspondence
#print axioms source_length
#print axioms source_occurrences
#print axioms construction_preserves_length
#print axioms construction_preserves_occurrences
#print axioms construction_is_seq
#print axioms construction_never_bag_or_set
#print axioms accepted_iff_source_sequence
#print axioms constructed_target_replays
#print axioms accepted_preserves_length_and_count
#print axioms changed_sequence_rejects
#print axioms reassociation_preserves_sequence
#print axioms distinct_order_is_observable
#print axioms duplicate_is_retained
#print axioms duplicate_deletion_rejects

end ACGN.Section3.DependentChainSequence
