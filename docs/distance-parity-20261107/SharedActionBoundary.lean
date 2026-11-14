import RepeatedOccurrenceBridge

/-!
Shared integration boundary of the non-temporal native-operation comparison.

The compared stream is heterogeneous. A `declarationPermutation` action carries
two ordinal arrays, a `declaration` action carries original binder ordinals, and
only a `matrix` action carries matrix occurrence paths. Slot 9
(`RepeatedOccurrenceTransport`/`RepeatedOccurrenceBridge`) is a theorem about
`Action`, whose coordinates are `Option Path`. This module states what that
theorem licenses on the mixed stream, and what it does not.

Part 1, stage dispatch. `transport` re-coordinates matrix actions with the
unchanged Slot 9 `mapBoth` and is the identity on every other stage. Proved:
the matrix projection of a transported stream is the Slot 9 transport of the
matrix projection; non-matrix actions, order, length and charge are unchanged;
`gate_matched_sound` and `gate_verdict_independent` lift to the mixed stream
with their premises required of matrix actions only; the stage-dispatching scan
is `none` exactly when no matrix coordinate is at or below a recorded class
member, agrees with the matrix-only scan on a matrix-only stream, is `none` for
empty classes and for any stream without matrix actions, and a `none` scan makes
the ordered verdict invariant under every composition of exchanges among
recorded class members. The wire decoder accepts a coordinate only in the shape
of its own stage; every other shape is an explicit error and one malformed
action rejects the whole stream, independently of the classes.

Part 2, declaration authority. The compared declaration actions are a function
of the selected native declaration program alone. A replayed program reads every
selected source occurrence and writes every selected target occurrence exactly
once and in the selected order; its kinds and charges are determined by its
index pairs, so no altered kind or charge replays. Equal original-coordinate
action lists of two replayed programs therefore have equal selected typed source
and target orders. Equal endpoints and equal totals do not determine the action
list: `SharedActionBoundaryWitness` instantiates that on retained source shapes.

Part 3, failure provenance. A failed explicit replay check and any other
consumer or schema execution error are different conclusions, both fatal, and
neither is ever a match, a discrepancy or an unexplained refusal.

Not claimed. That Java's paths, keys, atoms, addresses or JSON values equal this
model (Java correspondence obligations, listed in the review handoff); any
statement about the matrix stage of a particular pair; that equal declaration
actions imply equal selected binder maps; or any corpus, category or
certification result.
-/
namespace ACGN.FifthFive.SharedActionBoundary

open ACGN.FifthFive.RepeatedOccurrence

/-! ## Part 1. Stage-specific action coordinates -/

/-- One action of the compared stream. `δ` is the declaration payload, which the
matrix bridge never reads. -/
inductive Staged (δ : Type) where
  | permutation (source target : List Nat)
  | declaration (d : δ)
  | matrix (a : Action)
  deriving DecidableEq

section Stage
variable {δ : Type}

/-- Matrix coordinates go through the Slot 9 transport. Other stages are not
coordinates of the matrix endpoint and are returned unchanged. -/
def transport (f g : Path → Path) : Staged δ → Staged δ
  | .matrix a => .matrix (mapBoth f g a)
  | .permutation s t => .permutation s t
  | .declaration d => .declaration d

def isMatrix : Staged δ → Bool
  | .matrix _ => true
  | .permutation _ _ => false
  | .declaration _ => false

def matrixPart : List (Staged δ) → List Action
  | [] => []
  | .matrix a :: rest => a :: matrixPart rest
  | .permutation _ _ :: rest => matrixPart rest
  | .declaration _ :: rest => matrixPart rest

def stagedCost (declarationCost : δ → Nat) : Staged δ → Nat
  | .matrix a => a.cost
  | .declaration d => declarationCost d
  | .permutation _ _ => 0

def stagedCharge (declarationCost : δ → Nat) (xs : List (Staged δ)) : Nat :=
  (xs.map (stagedCost declarationCost)).sum

theorem transport_declaration (f g : Path → Path) (d : δ) :
    transport f g (Staged.declaration d) = Staged.declaration d := rfl

theorem transport_permutation (f g : Path → Path) (s t : List Nat) :
    transport f g (Staged.permutation s t : Staged δ) = Staged.permutation s t := rfl

/-- On a matrix action the staged transport is exactly the Slot 9 transport. -/
theorem transport_matrix (f g : Path → Path) (a : Action) :
    transport f g (Staged.matrix a : Staged δ) = Staged.matrix (mapBoth f g a) := rfl

theorem transport_nonmatrix (f g : Path → Path) (s : Staged δ) (h : isMatrix s = false) :
    transport f g s = s := by
  cases s with
  | permutation _ _ => rfl
  | declaration _ => rfl
  | matrix _ => simp [isMatrix] at h

theorem matrixPart_transport (f g : Path → Path) : ∀ (xs : List (Staged δ)),
    matrixPart (xs.map (transport f g)) = (matrixPart xs).map (mapBoth f g)
  | [] => rfl
  | .matrix a :: rest => by
    show mapBoth f g a :: matrixPart (rest.map (transport f g)) =
      mapBoth f g a :: (matrixPart rest).map (mapBoth f g)
    rw [matrixPart_transport f g rest]
  | .permutation _ _ :: rest => by
    show matrixPart (rest.map (transport f g)) = (matrixPart rest).map (mapBoth f g)
    exact matrixPart_transport f g rest
  | .declaration _ :: rest => by
    show matrixPart (rest.map (transport f g)) = (matrixPart rest).map (mapBoth f g)
    exact matrixPart_transport f g rest

/-- The non-matrix actions of a transported stream are the original ones, in
their original order. -/
theorem nonmatrix_transport (f g : Path → Path) : ∀ (xs : List (Staged δ)),
    (xs.map (transport f g)).filter (fun s => !isMatrix s) = xs.filter (fun s => !isMatrix s)
  | [] => rfl
  | .matrix a :: rest => by
    simp only [List.map_cons, transport, List.filter_cons]
    rw [nonmatrix_transport f g rest]
    simp [isMatrix]
  | .permutation s t :: rest => by
    simp only [List.map_cons, transport, List.filter_cons]
    rw [nonmatrix_transport f g rest]
  | .declaration d :: rest => by
    simp only [List.map_cons, transport, List.filter_cons]
    rw [nonmatrix_transport f g rest]

theorem stagedCost_transport (c : δ → Nat) (f g : Path → Path) (s : Staged δ) :
    stagedCost c (transport f g s) = stagedCost c s := by
  cases s with
  | permutation _ _ => rfl
  | declaration _ => rfl
  | matrix a => cases a; rfl

theorem stagedCharge_transport (c : δ → Nat) (f g : Path → Path) (xs : List (Staged δ)) :
    stagedCharge c (xs.map (transport f g)) = stagedCharge c xs := by
  induction xs with
  | nil => rfl
  | cons s rest ih =>
    simp only [stagedCharge, List.map_cons, List.sum_cons, stagedCost_transport] at ih ⊢
    rw [ih]

theorem transport_congr (f f' g g' : Path → Path) (s : Staged δ)
    (hs : ∀ a, s = Staged.matrix a → ∀ q, a.source = some q → f q = f' q)
    (ht : ∀ a, s = Staged.matrix a → ∀ q, a.target = some q → g q = g' q) :
    transport f g s = transport f' g' s := by
  cases s with
  | permutation _ _ => rfl
  | declaration _ => rfl
  | matrix a =>
    show Staged.matrix (mapBoth f g a) = Staged.matrix (mapBoth f' g' a)
    rw [mapBoth_congr f f' g g' a (hs a rfl) (ht a rfl)]

theorem transport_list_congr (f f' g g' : Path → Path) (xs : List (Staged δ))
    (hs : ∀ a, Staged.matrix a ∈ xs → ∀ q, a.source = some q → f q = f' q)
    (ht : ∀ a, Staged.matrix a ∈ xs → ∀ q, a.target = some q → g q = g' q) :
    xs.map (transport f g) = xs.map (transport f' g') := by
  induction xs with
  | nil => rfl
  | cons s rest ih =>
    have head : transport f g s = transport f' g' s :=
      transport_congr f f' g g' s
        (fun a ha => hs a (by subst ha; exact List.mem_cons_self ..))
        (fun a ha => ht a (by subst ha; exact List.mem_cons_self ..))
    have tail := ih (fun a ha => hs a (List.mem_cons_of_mem _ ha))
      (fun a ha => ht a (List.mem_cons_of_mem _ ha))
    simp only [List.map_cons, head, tail]

/-! ### Slot 9 verdicts on the mixed stream -/

def stagedClear (esL esR : List Exchange) : Staged δ → Bool
  | .matrix a => actionClear esL esR a
  | .permutation _ _ => true
  | .declaration _ => true

theorem transport_clear (esL esR : List Exchange) (s : Staged δ)
    (h : stagedClear esL esR s = true) : transport (swapAll esL) (swapAll esR) s = s := by
  cases s with
  | permutation _ _ => rfl
  | declaration _ => rfl
  | matrix a =>
    show Staged.matrix (mapBoth (swapAll esL) (swapAll esR) a) = Staged.matrix a
    rw [mapBoth_clear esL esR a h]

/-- `verdict_exchange_independent` for the mixed stream: only matrix actions
need be clear of the exchanged twins. -/
theorem staged_verdict_exchange_independent (esL esR : List Exchange)
    (bridged certified : List (Staged δ))
    (h : ∀ s ∈ bridged, stagedClear esL esR s = true) :
    (bridged.map (transport (swapAll esL) (swapAll esR)) = certified) ↔
      (bridged = certified) := by
  have fixed : bridged.map (transport (swapAll esL) (swapAll esR)) = bridged := by
    induction bridged with
    | nil => rfl
    | cons s rest ih =>
      have head := transport_clear esL esR s (h s (List.mem_cons_self ..))
      have tail := ih (fun b hb => h b (List.mem_cons_of_mem _ hb))
      simp only [List.map_cons, head, tail]
  rw [fixed]

def StagedWellPlaced (FL FR : Tree) : Staged δ → Prop
  | .matrix a => WellPlaced FL FR a
  | .permutation _ _ => True
  | .declaration _ => True

def StagedForced (KL KR : Keys) (FL CL FR CR : Tree) (mL mR : Path → List Nat) :
    Staged δ → Prop
  | .matrix a => ForcedCoordinates KL KR FL CL FR CR mL mR a
  | .permutation _ _ => True
  | .declaration _ => True

theorem stagedWellPlaced_matrix {FL FR : Tree} {a : Action}
    (h : StagedWellPlaced FL FR (Staged.matrix a : Staged δ)) : WellPlaced FL FR a := h

theorem stagedForced_matrix {KL KR : Keys} {FL CL FR CR : Tree} {mL mR : Path → List Nat}
    {a : Action} (h : StagedForced KL KR FL CL FR CR mL mR (Staged.matrix a : Staged δ)) :
    ForcedCoordinates KL KR FL CL FR CR mL mR a := h

/-- What a replay observes of a mixed-stream action: the resolved matrix
content, and a non-matrix action itself. -/
inductive Observed (δ : Type) where
  | permutation (source target : List Nat)
  | declaration (d : δ)
  | matrix (r : Resolved)

def observe (left right : Tree) : Staged δ → Observed δ
  | .matrix a => .matrix (resolve left right a)
  | .permutation s t => .permutation s t
  | .declaration d => .declaration d

theorem observe_list_congr (left right : Tree) (f f' g g' : Path → Path)
    (xs : List (Staged δ))
    (hs : ∀ a, Staged.matrix a ∈ xs → ∀ q, a.source = some q →
      get? (f q) left = get? (f' q) left)
    (ht : ∀ a, Staged.matrix a ∈ xs → ∀ q, a.target = some q →
      get? (g q) right = get? (g' q) right) :
    (xs.map (transport f g)).map (observe left right) =
      (xs.map (transport f' g')).map (observe left right) := by
  induction xs with
  | nil => rfl
  | cons s rest ih =>
    have tail := ih (fun a ha => hs a (List.mem_cons_of_mem _ ha))
      (fun a ha => ht a (List.mem_cons_of_mem _ ha))
    have head : observe left right (transport f g s) =
        observe left right (transport f' g' s) := by
      cases s with
      | permutation _ _ => rfl
      | declaration _ => rfl
      | matrix a =>
        show Observed.matrix (resolve left right (mapBoth f g a)) =
          Observed.matrix (resolve left right (mapBoth f' g' a))
        rw [resolve_congr left right f f' g g' a (hs a (List.mem_cons_self ..))
          (ht a (List.mem_cons_self ..))]
    simp only [List.map_cons, head, tail]

/-- `gate_matched_sound` for the mixed stream. The Slot 9 premises are required
of matrix actions only; non-matrix actions are observed literally. -/
theorem staged_gate_matched_sound (KL KR : Keys) (FL CL FR CR : Tree)
    (mL mR mL' mR' : Path → List Nat)
    (gL : GateBuilt KL FL CL mL) (gR : GateBuilt KR FR CR mR)
    (hL' : KeyPreserving KL FL CL mL') (hR' : KeyPreserving KR FR CR mR')
    (acts certified : List (Staged δ)) (hw : ∀ s ∈ acts, StagedWellPlaced FL FR s)
    (h : acts.map (transport (image mL []) (image mR [])) = certified) :
    (acts.map (transport (image mL' []) (image mR' []))).map (observe CL CR) =
      certified.map (observe CL CR) := by
  rw [← h]
  exact (observe_list_congr CL CR (image mL []) (image mL' []) (image mR []) (image mR' []) acts
    (fun a ha q hq => bridge_reads_agree KL FL CL mL mL' (gateBuilt_keyPreserving KL FL CL mL gL)
      hL' (gateBuilt_twinClosed KL FL CL mL gL) q ((stagedWellPlaced_matrix (hw _ ha)).1 q hq))
    (fun a ha q hq => bridge_reads_agree KR FR CR mR mR' (gateBuilt_keyPreserving KR FR CR mR gR)
      hR' (gateBuilt_twinClosed KR FR CR mR gR) q ((stagedWellPlaced_matrix (hw _ ha)).2 q hq))).symm

/-- `gate_verdict_independent` for the mixed stream. -/
theorem staged_gate_verdict_independent (KL KR : Keys) (FL CL FR CR : Tree)
    (mL mR mL' mR' : Path → List Nat)
    (gL : GateBuilt KL FL CL mL) (gR : GateBuilt KR FR CR mR)
    (hL' : KeyPreserving KL FL CL mL') (hR' : KeyPreserving KR FR CR mR')
    (acts certified : List (Staged δ)) (hw : ∀ s ∈ acts, StagedWellPlaced FL FR s)
    (hf : ∀ s ∈ acts, StagedForced KL KR FL CL FR CR mL mR s) :
    (acts.map (transport (image mL' []) (image mR' [])) = certified) ↔
      (acts.map (transport (image mL []) (image mR [])) = certified) := by
  have e : acts.map (transport (image mL' []) (image mR' [])) =
      acts.map (transport (image mL []) (image mR [])) :=
    transport_list_congr (image mL' []) (image mL []) (image mR' []) (image mR []) acts
      (fun a ha q hq => bridge_forced_unique KL FL CL mL mL' (gateBuilt_lands KL FL CL mL gL)
        (gateBuilt_keyPreserving KL FL CL mL gL) hL' q
        ((stagedWellPlaced_matrix (hw _ ha)).1 q hq) ((stagedForced_matrix (hf _ ha)).1 q hq))
      (fun a ha q hq => bridge_forced_unique KR FR CR mR mR' (gateBuilt_lands KR FR CR mR gR)
        (gateBuilt_keyPreserving KR FR CR mR gR) hR' q
        ((stagedWellPlaced_matrix (hw _ ha)).2 q hq) ((stagedForced_matrix (hf _ ha)).2 q hq))
  rw [e]

/-! ### The stage-dispatching ambiguity scan -/

/-- A recorded non-forced class: its certified parent and admitted children. -/
structure OccClass where
  parent : Path
  members : List Nat

/-- The coordinate is at or below a member of a recorded class. -/
def blockedBy (cs : List OccClass) (q : Path) : Bool :=
  cs.any fun c => c.members.any fun m => isPrefix (c.parent ++ [m]) q

def actionBlocked (src tgt : List OccClass) (a : Action) : Bool :=
  (match a.source with
    | none => false
    | some q => blockedBy src q) ||
  (match a.target with
    | none => false
    | some q => blockedBy tgt q)

/-- The scan as it was licensed: every action is a matrix action. -/
def scanMatrix (src tgt : List OccClass) : Nat → List Action → Option Nat
  | _, [] => none
  | i, a :: rest => if actionBlocked src tgt a then some i else scanMatrix src tgt (i + 1) rest

/-- The stage-dispatching scan: stream index of the first matrix action whose
coordinate is blocked. A non-matrix action is never read as a path. -/
def scanFrom (src tgt : List OccClass) : Nat → List (Staged δ) → Option Nat
  | _, [] => none
  | i, .matrix a :: rest =>
    if actionBlocked src tgt a then some i else scanFrom src tgt (i + 1) rest
  | i, .permutation _ _ :: rest => scanFrom src tgt (i + 1) rest
  | i, .declaration _ :: rest => scanFrom src tgt (i + 1) rest

def scan (src tgt : List OccClass) (xs : List (Staged δ)) : Option Nat := scanFrom src tgt 0 xs

/-- Existing behaviour is preserved on a matrix-only stream, index included. -/
theorem scanFrom_matrix_only (src tgt : List OccClass) : ∀ (i : Nat) (as : List Action),
    scanFrom src tgt i (as.map (Staged.matrix : Action → Staged δ)) = scanMatrix src tgt i as
  | _, [] => rfl
  | i, a :: rest => by
    show (if actionBlocked src tgt a then some i
        else scanFrom src tgt (i + 1) (rest.map (Staged.matrix : Action → Staged δ))) =
      (if actionBlocked src tgt a then some i else scanMatrix src tgt (i + 1) rest)
    rw [scanFrom_matrix_only src tgt (i + 1) rest]

theorem scanFrom_none_iff (src tgt : List OccClass) : ∀ (i : Nat) (xs : List (Staged δ)),
    scanFrom src tgt i xs = none ↔
      ∀ a, Staged.matrix a ∈ xs → actionBlocked src tgt a = false
  | _, [] => by
    constructor
    · intro _ a ha; cases ha
    · intro _; rfl
  | i, .matrix a :: rest => by
    have ih := scanFrom_none_iff src tgt (i + 1) rest
    show (if actionBlocked src tgt a then some i else scanFrom src tgt (i + 1) rest) = none ↔ _
    cases hb : actionBlocked src tgt a with
    | true =>
      constructor
      · intro h; simp at h
      · intro h
        have bad := h a (List.mem_cons_self ..)
        rw [hb] at bad; cases bad
    | false =>
      have reduce : (if false = true then some i else scanFrom src tgt (i + 1) rest) =
          scanFrom src tgt (i + 1) rest := by simp
      rw [reduce, ih]
      constructor
      · intro h b hbm
        cases List.mem_cons.mp hbm with
        | inl heq => cases heq; exact hb
        | inr hmem => exact h b hmem
      · intro h b hbm
        exact h b (List.mem_cons_of_mem _ hbm)
  | i, .permutation s t :: rest => by
    have ih := scanFrom_none_iff src tgt (i + 1) rest
    show scanFrom src tgt (i + 1) rest = none ↔ _
    rw [ih]
    constructor
    · intro h b hbm
      cases List.mem_cons.mp hbm with
      | inl heq => cases heq
      | inr hmem => exact h b hmem
    · intro h b hbm
      exact h b (List.mem_cons_of_mem _ hbm)
  | i, .declaration d :: rest => by
    have ih := scanFrom_none_iff src tgt (i + 1) rest
    show scanFrom src tgt (i + 1) rest = none ↔ _
    rw [ih]
    constructor
    · intro h b hbm
      cases List.mem_cons.mp hbm with
      | inl heq => cases heq
      | inr hmem => exact h b hmem
    · intro h b hbm
      exact h b (List.mem_cons_of_mem _ hbm)

theorem mem_matrixPart : ∀ (xs : List (Staged δ)) (a : Action),
    a ∈ matrixPart xs ↔ Staged.matrix a ∈ xs
  | [], a => by
    constructor
    · intro h; cases h
    · intro h; cases h
  | .matrix b :: rest, a => by
    have ih := mem_matrixPart rest a
    show a ∈ b :: matrixPart rest ↔ _
    constructor
    · intro h
      cases List.mem_cons.mp h with
      | inl heq => rw [heq]; exact List.mem_cons_self ..
      | inr hmem => exact List.mem_cons_of_mem _ (ih.mp hmem)
    · intro h
      cases List.mem_cons.mp h with
      | inl heq => cases heq; exact List.mem_cons_self ..
      | inr hmem => exact List.mem_cons_of_mem _ (ih.mpr hmem)
  | .permutation s t :: rest, a => by
    have ih := mem_matrixPart rest a
    show a ∈ matrixPart rest ↔ _
    constructor
    · intro h; exact List.mem_cons_of_mem _ (ih.mp h)
    · intro h
      cases List.mem_cons.mp h with
      | inl heq => cases heq
      | inr hmem => exact ih.mpr hmem
  | .declaration d :: rest, a => by
    have ih := mem_matrixPart rest a
    show a ∈ matrixPart rest ↔ _
    constructor
    · intro h; exact List.mem_cons_of_mem _ (ih.mp h)
    · intro h
      cases List.mem_cons.mp h with
      | inl heq => cases heq
      | inr hmem => exact ih.mpr hmem

/-- The scan verdict is a function of the matrix projection: no declaration or
permutation action can create, remove or move an ambiguity refusal. -/
theorem scan_depends_on_matrixPart (src tgt : List OccClass) (xs ys : List (Staged δ))
    (h : matrixPart xs = matrixPart ys) : scan src tgt xs = none ↔ scan src tgt ys = none := by
  show scanFrom src tgt 0 xs = none ↔ scanFrom src tgt 0 ys = none
  rw [scanFrom_none_iff, scanFrom_none_iff]
  constructor
  · intro hx a ha
    have m : a ∈ matrixPart xs := by rw [h]; exact (mem_matrixPart ys a).mpr ha
    exact hx a ((mem_matrixPart xs a).mp m)
  · intro hy a ha
    have m : a ∈ matrixPart ys := by rw [← h]; exact (mem_matrixPart xs a).mpr ha
    exact hy a ((mem_matrixPart ys a).mp m)

theorem blockedBy_nil (q : Path) : blockedBy [] q = false := rfl

/-- Empty classes never refuse, whatever stages the stream contains. -/
theorem scan_empty_classes (xs : List (Staged δ)) : scan [] [] xs = none := by
  show scanFrom [] [] 0 xs = none
  rw [scanFrom_none_iff]
  intro a _
  cases a with
  | mk kind cost source target =>
    cases source <;> cases target <;> rfl

/-- A stream without matrix actions never refuses, whatever the classes. -/
theorem scan_nonmatrix_stream (src tgt : List OccClass) (xs : List (Staged δ))
    (h : ∀ s ∈ xs, isMatrix s = false) : scan src tgt xs = none := by
  show scanFrom src tgt 0 xs = none
  rw [scanFrom_none_iff]
  intro a ha
  have bad := h _ ha
  simp [isMatrix] at bad

/-- A reported index addresses a blocked matrix action of the mixed stream. -/
theorem scanFrom_some_sound (src tgt : List OccClass) : ∀ (xs : List (Staged δ)) (i k : Nat),
    scanFrom src tgt i xs = some k →
      i ≤ k ∧ ∃ a, xs[k - i]? = some (Staged.matrix a) ∧ actionBlocked src tgt a = true
  | [], _, _, h => by cases h
  | .matrix a :: rest, i, k, h => by
    have h' : (if actionBlocked src tgt a then some i else scanFrom src tgt (i + 1) rest) =
        some k := h
    cases hb : actionBlocked src tgt a with
    | true =>
      rw [hb] at h'
      have hk : i = k := by simpa using h'
      subst hk
      exact ⟨Nat.le_refl _, a, by simp, hb⟩
    | false =>
      rw [hb] at h'
      have h'' : scanFrom src tgt (i + 1) rest = some k := by simpa using h'
      obtain ⟨hle, b, hget, hblocked⟩ := scanFrom_some_sound src tgt rest (i + 1) k h''
      refine ⟨by omega, b, ?_, hblocked⟩
      have step : k - i = (k - (i + 1)) + 1 := by omega
      rw [step, List.getElem?_cons_succ]
      exact hget
  | .permutation s t :: rest, i, k, h => by
    have h' : scanFrom src tgt (i + 1) rest = some k := h
    obtain ⟨hle, b, hget, hblocked⟩ := scanFrom_some_sound src tgt rest (i + 1) k h'
    refine ⟨by omega, b, ?_, hblocked⟩
    have step : k - i = (k - (i + 1)) + 1 := by omega
    rw [step, List.getElem?_cons_succ]
    exact hget
  | .declaration d :: rest, i, k, h => by
    have h' : scanFrom src tgt (i + 1) rest = some k := h
    obtain ⟨hle, b, hget, hblocked⟩ := scanFrom_some_sound src tgt rest (i + 1) k h'
    refine ⟨by omega, b, ?_, hblocked⟩
    have step : k - i = (k - (i + 1)) + 1 := by omega
    rw [step, List.getElem?_cons_succ]
    exact hget

/-- The exchange is between two admitted children of one recorded class. -/
def ExchangeIn (cs : List OccClass) (e : Exchange) : Prop :=
  ∃ c, c ∈ cs ∧ e.parent = c.parent ∧ e.j ∈ c.members ∧ e.k ∈ c.members

theorem blockedBy_false (cs : List OccClass) (q : Path) (h : blockedBy cs q = false)
    (c : OccClass) (hc : c ∈ cs) (m : Nat) (hm : m ∈ c.members) :
    isPrefix (c.parent ++ [m]) q = false := by
  cases hp : isPrefix (c.parent ++ [m]) q with
  | false => rfl
  | true =>
    have blocked : blockedBy cs q = true :=
      List.any_eq_true.mpr ⟨c, hc, List.any_eq_true.mpr ⟨m, hm, hp⟩⟩
    rw [blocked] at h; cases h

theorem pathClear_of_not_blocked (cs : List OccClass) (e : Exchange) (q : Path)
    (he : ExchangeIn cs e) (h : blockedBy cs q = false) : pathClear e q = true := by
  obtain ⟨c, hc, hp, hj, hk⟩ := he
  have h1 := blockedBy_false cs q h c hc e.j hj
  have h2 := blockedBy_false cs q h c hc e.k hk
  simp [pathClear, hp, h1, h2]

theorem actionClear_of_not_blocked (src tgt : List OccClass) (esL esR : List Exchange)
    (hL : ∀ e ∈ esL, ExchangeIn src e) (hR : ∀ e ∈ esR, ExchangeIn tgt e)
    (a : Action) (h : actionBlocked src tgt a = false) : actionClear esL esR a = true := by
  unfold actionBlocked at h
  have hboth := Bool.or_eq_false_iff.mp h
  unfold actionClear
  apply Bool.and_eq_true_iff.mpr
  constructor
  · cases hs : a.source with
    | none => rfl
    | some q =>
      apply List.all_eq_true.mpr
      intro e he
      exact pathClear_of_not_blocked src e q (hL e he) (by simpa [hs] using hboth.1)
  · cases ht : a.target with
    | none => rfl
    | some q =>
      apply List.all_eq_true.mpr
      intro e he
      exact pathClear_of_not_blocked tgt e q (hR e he) (by simpa [ht] using hboth.2)

/-- The mixed-stream guarantee behind a demonstrated discrepancy. When the
stage-dispatching scan finds no blocked matrix coordinate, the ordered verdict
on the whole heterogeneous stream is the same before and after every
composition of exchanges among the recorded class members. -/
theorem scan_clear_verdict_independent (src tgt : List OccClass) (esL esR : List Exchange)
    (hL : ∀ e ∈ esL, ExchangeIn src e) (hR : ∀ e ∈ esR, ExchangeIn tgt e)
    (bridged certified : List (Staged δ)) (h : scan src tgt bridged = none) :
    (bridged.map (transport (swapAll esL) (swapAll esR)) = certified) ↔
      (bridged = certified) := by
  apply staged_verdict_exchange_independent
  intro s hs
  cases s with
  | permutation _ _ => rfl
  | declaration _ => rfl
  | matrix a =>
    exact actionClear_of_not_blocked src tgt esL esR hL hR a
      ((scanFrom_none_iff src tgt 0 bridged).mp h a hs)

end Stage

/-! ### Wire shapes: a coordinate is accepted only in its own stage's shape -/

/-- The shapes a JSON coordinate can have. `other` is every remaining value. -/
inductive Wire where
  | null
  | nat (n : Nat)
  | text (s : String)
  | nats (xs : List Nat)
  | other

structure WireDeclaration where
  kind : String
  cost : Nat
  source : Option Nat
  target : Option Nat
  sourceTuple : Option (List String)
  targetTuple : Option (List String)

structure RawAction where
  stage : String
  kind : String
  cost : Nat
  source : Wire
  target : Wire
  sourceTuple : Option (List String)
  targetTuple : Option (List String)

/-- Both coordinates must decode; the first error is the result. -/
def both {α β : Type} (a b : Except String α) (k : α → α → Except String β) : Except String β :=
  match a, b with
  | .ok x, .ok y => k x y
  | .error e, _ => .error e
  | .ok _, .error e => .error e

theorem both_ok {α β : Type} (a b : Except String α) (k : α → α → Except String β) (z : β)
    (h : both a b k = .ok z) : ∃ x y, a = .ok x ∧ b = .ok y ∧ k x y = .ok z := by
  cases a with
  | error e => cases h
  | ok x =>
    cases b with
    | error e => cases h
    | ok y => exact ⟨x, y, rfl, rfl, h⟩

theorem both_of_ok {α β : Type} (a b : Except String α) (k : α → α → Except String β) (x y : α)
    (ha : a = .ok x) (hb : b = .ok y) : both a b k = k x y := by
  subst ha; subst hb; rfl

def ordinalCoordinate : Wire → Except String (Option Nat)
  | .null => .ok none
  | .nat n => .ok (some n)
  | .text _ => .error "DECLARATION_COORDINATE_NOT_AN_ORDINAL"
  | .nats _ => .error "DECLARATION_COORDINATE_NOT_AN_ORDINAL"
  | .other => .error "DECLARATION_COORDINATE_NOT_AN_ORDINAL"

def permutationCoordinate : Wire → Except String (List Nat)
  | .nats xs => .ok xs
  | .null => .error "PERMUTATION_COORDINATE_NOT_AN_ORDINAL_ARRAY"
  | .nat _ => .error "PERMUTATION_COORDINATE_NOT_AN_ORDINAL_ARRAY"
  | .text _ => .error "PERMUTATION_COORDINATE_NOT_AN_ORDINAL_ARRAY"
  | .other => .error "PERMUTATION_COORDINATE_NOT_AN_ORDINAL_ARRAY"

section Decode
-- The matrix path grammar. A text outside the grammar has no path.
variable (parse : String → Option Path)

def matrixCoordinate : Wire → Except String (Option Path)
  | .null => .ok none
  | .text s =>
    match parse s with
    | some p => .ok (some p)
    | none => .error "MALFORMED_MATRIX_PATH"
  | .nat _ => .error "MATRIX_COORDINATE_NOT_A_PATH"
  | .nats _ => .error "MATRIX_COORDINATE_NOT_A_PATH"
  | .other => .error "MATRIX_COORDINATE_NOT_A_PATH"

def decode (r : RawAction) : Except String (Staged WireDeclaration) :=
  if r.stage = "matrix" then
    both (matrixCoordinate parse r.source) (matrixCoordinate parse r.target)
      (fun s t => .ok (.matrix ⟨r.kind, r.cost, s, t⟩))
  else if r.stage = "declaration" then
    both (ordinalCoordinate r.source) (ordinalCoordinate r.target)
      (fun s t => .ok (.declaration ⟨r.kind, r.cost, s, t, r.sourceTuple, r.targetTuple⟩))
  else if r.stage = "declarationPermutation" then
    both (permutationCoordinate r.source) (permutationCoordinate r.target)
      (fun s t => if r.cost = 0 then .ok (.permutation s t) else .error "PERMUTATION_CHARGE")
  else .error "UNKNOWN_ACTION_STAGE"

/-- Inversion: an accepted action has its own stage's coordinate shapes and is
decoded to exactly its own content. There is no coercion between stages. -/
theorem decode_ok (r : RawAction) (x : Staged WireDeclaration) (h : decode parse r = .ok x) :
    (r.stage = "matrix" ∧ ∃ s t, matrixCoordinate parse r.source = .ok s ∧
        matrixCoordinate parse r.target = .ok t ∧
        x = Staged.matrix ⟨r.kind, r.cost, s, t⟩) ∨
    (r.stage = "declaration" ∧ ∃ s t, ordinalCoordinate r.source = .ok s ∧
        ordinalCoordinate r.target = .ok t ∧
        x = Staged.declaration ⟨r.kind, r.cost, s, t, r.sourceTuple, r.targetTuple⟩) ∨
    (r.stage = "declarationPermutation" ∧ r.cost = 0 ∧ ∃ s t,
        permutationCoordinate r.source = .ok s ∧ permutationCoordinate r.target = .ok t ∧
        x = Staged.permutation s t) := by
  unfold decode at h
  by_cases hm : r.stage = "matrix"
  · rw [ite_eq_left hm] at h
    obtain ⟨s, t, hs, ht, hk⟩ := both_ok _ _ _ _ h
    exact Or.inl ⟨hm, s, t, hs, ht, (Except.ok.inj hk).symm⟩
  · rw [ite_eq_right hm] at h
    by_cases hd : r.stage = "declaration"
    · rw [ite_eq_left hd] at h
      obtain ⟨s, t, hs, ht, hk⟩ := both_ok _ _ _ _ h
      exact Or.inr (Or.inl ⟨hd, s, t, hs, ht, (Except.ok.inj hk).symm⟩)
    · rw [ite_eq_right hd] at h
      by_cases hp : r.stage = "declarationPermutation"
      · rw [ite_eq_left hp] at h
        obtain ⟨s, t, hs, ht, hk⟩ := both_ok _ _ _ _ h
        by_cases hc : r.cost = 0
        · have hk' : (Except.ok (Staged.permutation s t) : Except String (Staged WireDeclaration)) =
              .ok x := by simpa [hc] using hk
          exact Or.inr (Or.inr ⟨hp, hc, s, t, hs, ht, (Except.ok.inj hk').symm⟩)
        · simp [hc] at hk
      · rw [ite_eq_right hp] at h
        cases h

/-- A validated declaration action is carried over unchanged. -/
theorem decode_declaration (r : RawAction) (s t : Option Nat)
    (hstage : r.stage = "declaration")
    (hs : ordinalCoordinate r.source = .ok s) (ht : ordinalCoordinate r.target = .ok t) :
    decode parse r =
      .ok (Staged.declaration ⟨r.kind, r.cost, s, t, r.sourceTuple, r.targetTuple⟩) := by
  have notMatrix : ¬ r.stage = "matrix" := by rw [hstage]; decide
  unfold decode
  rw [ite_eq_right notMatrix, ite_eq_left hstage, both_of_ok _ _ _ s t hs ht]

/-- A validated permutation action is carried over unchanged. -/
theorem decode_permutation (r : RawAction) (s t : List Nat)
    (hstage : r.stage = "declarationPermutation") (hc : r.cost = 0)
    (hs : permutationCoordinate r.source = .ok s)
    (ht : permutationCoordinate r.target = .ok t) :
    decode parse r = .ok (Staged.permutation s t) := by
  have notMatrix : ¬ r.stage = "matrix" := by rw [hstage]; decide
  have notDeclaration : ¬ r.stage = "declaration" := by rw [hstage]; decide
  unfold decode
  rw [ite_eq_right notMatrix, ite_eq_right notDeclaration, ite_eq_left hstage, both_of_ok _ _ _ s t hs ht]
  simp [hc]

theorem decode_matrix (r : RawAction) (s t : Option Path) (hstage : r.stage = "matrix")
    (hs : matrixCoordinate parse r.source = .ok s)
    (ht : matrixCoordinate parse r.target = .ok t) :
    decode parse r = .ok (Staged.matrix ⟨r.kind, r.cost, s, t⟩) := by
  unfold decode
  rw [ite_eq_left hstage, both_of_ok _ _ _ s t hs ht]

/-- A matrix coordinate is `null` or a text of the path grammar. -/
theorem matrixCoordinate_ok (w : Wire) (p : Option Path)
    (h : matrixCoordinate parse w = .ok p) :
    (w = Wire.null ∧ p = none) ∨ ∃ s q, w = Wire.text s ∧ parse s = some q ∧ p = some q := by
  cases w with
  | null =>
    have hp : (Except.ok none : Except String (Option Path)) = .ok p := h
    exact Or.inl ⟨rfl, (Except.ok.inj hp).symm⟩
  | text s =>
    cases hq : parse s with
    | none =>
      simp [matrixCoordinate, hq] at h
    | some q =>
      have hp : (Except.ok (some q) : Except String (Option Path)) = .ok p := by
        simpa [matrixCoordinate, hq] using h
      exact Or.inr ⟨s, q, rfl, hq, (Except.ok.inj hp).symm⟩
  | nat n => cases h
  | nats xs => cases h
  | other => cases h

/-- The historical failure shape: an ordinal presented as a matrix coordinate
is rejected, not coerced. -/
theorem matrix_stage_rejects_ordinal (r : RawAction) (n : Nat) (hstage : r.stage = "matrix")
    (h : r.source = Wire.nat n ∨ r.target = Wire.nat n) (x : Staged WireDeclaration) :
    decode parse r ≠ .ok x := by
  intro hx
  rcases decode_ok parse r x hx with ⟨_, s, t, hs, ht, _⟩ | ⟨hd, _⟩ | ⟨hp, _⟩
  · cases h with
    | inl h => rw [h] at hs; cases hs
    | inr h => rw [h] at ht; cases ht
  · rw [hstage] at hd; exact absurd hd (by decide)
  · rw [hstage] at hp; exact absurd hp (by decide)

/-- A permutation array presented as a matrix coordinate is rejected. -/
theorem matrix_stage_rejects_array (r : RawAction) (xs : List Nat) (hstage : r.stage = "matrix")
    (h : r.source = Wire.nats xs ∨ r.target = Wire.nats xs) (x : Staged WireDeclaration) :
    decode parse r ≠ .ok x := by
  intro hx
  rcases decode_ok parse r x hx with ⟨_, s, t, hs, ht, _⟩ | ⟨hd, _⟩ | ⟨hp, _⟩
  · cases h with
    | inl h => rw [h] at hs; cases hs
    | inr h => rw [h] at ht; cases ht
  · rw [hstage] at hd; exact absurd hd (by decide)
  · rw [hstage] at hp; exact absurd hp (by decide)

/-- A text presented as a declaration ordinal is rejected, not parsed. -/
theorem declaration_stage_rejects_text (r : RawAction) (s : String)
    (hstage : r.stage = "declaration")
    (h : r.source = Wire.text s ∨ r.target = Wire.text s) (x : Staged WireDeclaration) :
    decode parse r ≠ .ok x := by
  intro hx
  rcases decode_ok parse r x hx with ⟨hm, _⟩ | ⟨_, a, b, hs, ht, _⟩ | ⟨hp, _⟩
  · rw [hstage] at hm; exact absurd hm (by decide)
  · cases h with
    | inl h => rw [h] at hs; cases hs
    | inr h => rw [h] at ht; cases ht
  · rw [hstage] at hp; exact absurd hp (by decide)

theorem unknown_stage_rejected (r : RawAction) (h1 : ¬ r.stage = "matrix")
    (h2 : ¬ r.stage = "declaration") (h3 : ¬ r.stage = "declarationPermutation") :
    decode parse r = .error "UNKNOWN_ACTION_STAGE" := by
  unfold decode
  rw [ite_eq_right h1, ite_eq_right h2, ite_eq_right h3]

/-- The whole stream is decoded before it is scanned. -/
def decodeAll : List RawAction → Except String (List (Staged WireDeclaration))
  | [] => .ok []
  | r :: rest =>
    match decode parse r with
    | .error e => .error e
    | .ok x =>
      match decodeAll rest with
      | .error e => .error e
      | .ok xs => .ok (x :: xs)

/-- No action is skipped: every action of an accepted stream decoded. -/
theorem decodeAll_all_ok : ∀ (rs : List RawAction) (xs : List (Staged WireDeclaration)),
    decodeAll parse rs = .ok xs → ∀ r ∈ rs, ∃ x, decode parse r = .ok x
  | [], _, _ => by intro r hr; cases hr
  | r :: rest, xs, h => by
    intro r' hr'
    cases hd : decode parse r with
    | error e => simp [decodeAll, hd] at h
    | ok x =>
      cases hrest : decodeAll parse rest with
      | error e => simp [decodeAll, hd, hrest] at h
      | ok ys =>
        cases List.mem_cons.mp hr' with
        | inl heq => rw [heq]; exact ⟨x, hd⟩
        | inr hmem => exact decodeAll_all_ok rest ys hrest r' hmem

theorem decodeAll_length : ∀ (rs : List RawAction) (xs : List (Staged WireDeclaration)),
    decodeAll parse rs = .ok xs → xs.length = rs.length
  | [], xs, h => by
    have hx : (Except.ok [] : Except String (List (Staged WireDeclaration))) = .ok xs := h
    rw [← Except.ok.inj hx]
    rfl
  | r :: rest, xs, h => by
    cases hd : decode parse r with
    | error e => simp [decodeAll, hd] at h
    | ok x =>
      cases hrest : decodeAll parse rest with
      | error e => simp [decodeAll, hd, hrest] at h
      | ok ys =>
        have hx : (Except.ok (x :: ys) : Except String (List (Staged WireDeclaration))) =
            .ok xs := by simpa [decodeAll, hd, hrest] using h
        rw [← Except.ok.inj hx, List.length_cons, List.length_cons,
          decodeAll_length rest ys hrest]

def scanRaw (src tgt : List OccClass) (rs : List RawAction) : Except String (Option Nat) :=
  match decodeAll parse rs with
  | .error e => .error e
  | .ok xs => .ok (scan src tgt xs)

/-- Malformed-coordinate rejection. One action that does not decode rejects the
scan for every pair of classes, empty classes included. -/
theorem scanRaw_malformed (src tgt : List OccClass) (rs : List RawAction) (r : RawAction)
    (hr : r ∈ rs) (hbad : ∀ x, decode parse r ≠ .ok x) (v : Option Nat) :
    scanRaw parse src tgt rs ≠ .ok v := by
  intro hv
  cases hd : decodeAll parse rs with
  | error e => simp [scanRaw, hd] at hv
  | ok xs =>
    obtain ⟨x, hx⟩ := decodeAll_all_ok parse rs xs hd r hr
    exact hbad x hx

end Decode

/-! ## Part 2. Selected native declaration authority -/

inductive DKind where
  | insert
  | delete
  | keep
  | update
  deriving DecidableEq

/-- An authenticated original declaration: its binder ordinal and repair tuple
`τ` (quantifier, type, cardinality, disjointness class). -/
structure Origin (τ : Type) where
  ordinal : Nat
  tuple : τ
  deriving DecidableEq

/-- One operation of a native declaration program; `left`/`right` index the
selected source/target orders. -/
structure Op where
  kind : DKind
  cost : Nat
  left : Option Nat
  right : Option Nat
  deriving DecidableEq

/-- A declaration action in original coordinates, as it is compared. -/
structure NativeAction (τ : Type) where
  kind : DKind
  cost : Nat
  source : Option Nat
  target : Option Nat
  sourceTuple : Option τ
  targetTuple : Option τ
  deriving DecidableEq

section Program
variable {τ : Type} [DecidableEq τ]

/-- The kind and charge the fixed-list replay requires of an index pair. -/
def expected (src tgt : List (Origin τ)) : Option Nat → Option Nat → Option (DKind × Nat)
  | some l, none => (src[l]?).map fun _ => (DKind.delete, 1)
  | none, some r => (tgt[r]?).map fun _ => (DKind.insert, 1)
  | some l, some r =>
    match src[l]?, tgt[r]? with
    | some a, some b => some (if a.tuple = b.tuple then (DKind.keep, 0) else (DKind.update, 1))
    | some _, none => none
    | none, _ => none
  | none, none => none

abbrev StepOk (src tgt : List (Origin τ)) (i j : Nat) (op : Op) : Prop :=
  (op.left = none ∨ op.left = some i) ∧ (op.right = none ∨ op.right = some j) ∧
    expected src tgt op.left op.right = some (op.kind, op.cost)

def nextLeft (i : Nat) (op : Op) : Nat := if op.left.isSome then i + 1 else i
def nextRight (j : Nat) (op : Op) : Nat := if op.right.isSome then j + 1 else j

/-- The fixed-list replay: cursors advance in order, every kind and charge is
the required one, and both lists are exhausted. No search, no minimum. -/
def check (src tgt : List (Origin τ)) : Nat → Nat → List Op → Bool
  | i, j, [] => decide (i = src.length ∧ j = tgt.length)
  | i, j, op :: rest =>
    decide (StepOk src tgt i j op) && check src tgt (nextLeft i op) (nextRight j op) rest

def programCost (ops : List Op) : Nat := (ops.map Op.cost).sum

def sourceOrigin (src : List (Origin τ)) (op : Op) : Option (Origin τ) :=
  op.left.bind fun l => src[l]?

def targetOrigin (tgt : List (Origin τ)) (op : Op) : Option (Origin τ) :=
  op.right.bind fun r => tgt[r]?

def emit (src tgt : List (Origin τ)) (op : Op) : NativeAction τ :=
  { kind := op.kind, cost := op.cost,
    source := (sourceOrigin src op).map Origin.ordinal,
    target := (targetOrigin tgt op).map Origin.ordinal,
    sourceTuple := (sourceOrigin src op).map Origin.tuple,
    targetTuple := (targetOrigin tgt op).map Origin.tuple }

/-- The compared actions: one per native operation, in native order. -/
def nativeActions (src tgt : List (Origin τ)) (ops : List Op) : List (NativeAction τ) :=
  ops.map (emit src tgt)

omit [DecidableEq τ] in
theorem nativeActions_length (src tgt : List (Origin τ)) (ops : List Op) :
    (nativeActions src tgt ops).length = ops.length := List.length_map ..

omit [DecidableEq τ] in
theorem nativeActions_kinds (src tgt : List (Origin τ)) (ops : List Op) :
    (nativeActions src tgt ops).map NativeAction.kind = ops.map Op.kind := by
  induction ops with
  | nil => rfl
  | cons op rest ih =>
    show op.kind :: (nativeActions src tgt rest).map NativeAction.kind = op.kind :: rest.map Op.kind
    rw [ih]

omit [DecidableEq τ] in
theorem nativeActions_costs (src tgt : List (Origin τ)) (ops : List Op) :
    (nativeActions src tgt ops).map NativeAction.cost = ops.map Op.cost := by
  induction ops with
  | nil => rfl
  | cons op rest ih =>
    show op.cost :: (nativeActions src tgt rest).map NativeAction.cost = op.cost :: rest.map Op.cost
    rw [ih]

omit [DecidableEq τ] in
theorem nativeActions_charge (src tgt : List (Origin τ)) (ops : List Op) :
    ((nativeActions src tgt ops).map NativeAction.cost).sum = programCost ops := by
  rw [nativeActions_costs]; rfl

/-- The evidence of one arm. The supplemental slice is retained beside the
selected native program. -/
structure ArmEvidence (τ : Type) where
  nativeSource : List (Origin τ)
  nativeTarget : List (Origin τ)
  nativeOps : List Op
  supplementalSource : List (Origin τ)
  supplementalTarget : List (Origin τ)
  supplementalOps : List Op

/-- What is compared across arms. -/
def compared (e : ArmEvidence τ) : List (NativeAction τ) :=
  nativeActions e.nativeSource e.nativeTarget e.nativeOps

/-- What is retained as a diagnostic. -/
def supplementalDiagnostic (e : ArmEvidence τ) : List (NativeAction τ) :=
  nativeActions e.supplementalSource e.supplementalTarget e.supplementalOps

omit [DecidableEq τ] in
/-- Authority. No supplemental slice changes the compared actions. -/
theorem compared_ignores_supplemental (e : ArmEvidence τ) (s t : List (Origin τ))
    (ops : List Op) :
    compared { e with supplementalSource := s, supplementalTarget := t, supplementalOps := ops } = compared e := rfl

def readOrigin (x : NativeAction τ) : Option (Origin τ) :=
  match x.source, x.sourceTuple with
  | some o, some t => some ⟨o, t⟩
  | some _, none => none
  | none, _ => none

def writtenOrigin (x : NativeAction τ) : Option (Origin τ) :=
  match x.target, x.targetTuple with
  | some o, some t => some ⟨o, t⟩
  | some _, none => none
  | none, _ => none

/-- The typed original occurrences an action list reads, in order. -/
def consumed (xs : List (NativeAction τ)) : List (Origin τ) := xs.filterMap readOrigin

/-- The typed original occurrences an action list writes, in order. -/
def produced (xs : List (NativeAction τ)) : List (Origin τ) := xs.filterMap writtenOrigin

omit [DecidableEq τ] in
theorem readOrigin_emit (src tgt : List (Origin τ)) (op : Op) :
    readOrigin (emit src tgt op) = sourceOrigin src op := by
  show (match (sourceOrigin src op).map Origin.ordinal, (sourceOrigin src op).map Origin.tuple with
    | some o, some t => some (Origin.mk o t)
    | some _, none => none
    | none, _ => none) = sourceOrigin src op
  cases sourceOrigin src op with
  | none => rfl
  | some a => rfl

omit [DecidableEq τ] in
theorem writtenOrigin_emit (src tgt : List (Origin τ)) (op : Op) :
    writtenOrigin (emit src tgt op) = targetOrigin tgt op := by
  show (match (targetOrigin tgt op).map Origin.ordinal, (targetOrigin tgt op).map Origin.tuple with
    | some o, some t => some (Origin.mk o t)
    | some _, none => none
    | none, _ => none) = targetOrigin tgt op
  cases targetOrigin tgt op with
  | none => rfl
  | some a => rfl

omit [DecidableEq τ] in
theorem consumed_native (src tgt : List (Origin τ)) (ops : List Op) :
    consumed (nativeActions src tgt ops) = ops.filterMap (sourceOrigin src) := by
  induction ops with
  | nil => rfl
  | cons op rest ih =>
    show List.filterMap readOrigin (emit src tgt op :: nativeActions src tgt rest) =
      List.filterMap (sourceOrigin src) (op :: rest)
    have tail : List.filterMap readOrigin (nativeActions src tgt rest) =
        List.filterMap (sourceOrigin src) rest := ih
    simp only [List.filterMap_cons, readOrigin_emit, tail]

omit [DecidableEq τ] in
theorem produced_native (src tgt : List (Origin τ)) (ops : List Op) :
    produced (nativeActions src tgt ops) = ops.filterMap (targetOrigin tgt) := by
  induction ops with
  | nil => rfl
  | cons op rest ih =>
    show List.filterMap writtenOrigin (emit src tgt op :: nativeActions src tgt rest) =
      List.filterMap (targetOrigin tgt) (op :: rest)
    have tail : List.filterMap writtenOrigin (nativeActions src tgt rest) =
        List.filterMap (targetOrigin tgt) rest := ih
    simp only [List.filterMap_cons, writtenOrigin_emit, tail]

theorem drop_of_getElem? {α : Type} : ∀ (l : List α) (i : Nat) (a : α),
    l[i]? = some a → l.drop i = a :: l.drop (i + 1)
  | [], _, _, h => by simp at h
  | x :: l, 0, a, h => by
    have hx : x = a := by simpa using h
    simp [hx]
  | x :: l, i + 1, a, h => by
    have h' : l[i]? = some a := by simpa using h
    simpa using drop_of_getElem? l i a h'

theorem some_eq_of_or {α : Type} {x y : α} (h : some x = none ∨ some x = some y) : x = y := by
  cases h with
  | inl h0 => cases h0
  | inr h1 => exact Option.some.inj h1

/-- A replayed suffix reads exactly the remaining selected source occurrences
and writes exactly the remaining selected target occurrences, in order. -/
theorem check_reads (src tgt : List (Origin τ)) : ∀ (ops : List Op) (i j : Nat),
    check src tgt i j ops = true →
      ops.filterMap (sourceOrigin src) = src.drop i ∧
      ops.filterMap (targetOrigin tgt) = tgt.drop j
  | [], i, j, h => by
    have hij : i = src.length ∧ j = tgt.length := by simpa [check] using h
    obtain ⟨hi, hj⟩ := hij
    subst hi; subst hj
    simp
  | op :: rest, i, j, h => by
    have hsplit : StepOk src tgt i j op ∧
        check src tgt (nextLeft i op) (nextRight j op) rest = true := by
      simpa [check] using h
    obtain ⟨⟨hl, hr, hexp⟩, hrest⟩ := hsplit
    obtain ⟨ihs, iht⟩ := check_reads src tgt rest (nextLeft i op) (nextRight j op) hrest
    simp only [List.filterMap_cons]
    cases hleft : op.left with
    | none =>
      have e1 : nextLeft i op = i := by simp [nextLeft, hleft]
      have s1 : sourceOrigin src op = none := by simp [sourceOrigin, hleft]
      rw [e1] at ihs
      cases hright : op.right with
      | none =>
        rw [hleft, hright] at hexp
        simp [expected] at hexp
      | some r =>
        rw [hright] at hr
        have hrj : r = j := some_eq_of_or hr
        subst hrj
        rw [hleft, hright] at hexp
        cases hb : tgt[r]? with
        | none => simp [expected, hb] at hexp
        | some b =>
          have e2 : nextRight r op = r + 1 := by simp [nextRight, hright]
          have s2 : targetOrigin tgt op = some b := by simp [targetOrigin, hright, hb]
          rw [e2] at iht
          rw [s1, s2, ihs, iht, drop_of_getElem? tgt r b hb]
          exact ⟨rfl, rfl⟩
    | some l =>
      rw [hleft] at hl
      have hli : l = i := some_eq_of_or hl
      subst hli
      have e1 : nextLeft l op = l + 1 := by simp [nextLeft, hleft]
      rw [e1] at ihs
      cases hright : op.right with
      | none =>
        have e2 : nextRight j op = j := by simp [nextRight, hright]
        have s2 : targetOrigin tgt op = none := by simp [targetOrigin, hright]
        rw [e2] at iht
        rw [hleft, hright] at hexp
        cases ha : src[l]? with
        | none => simp [expected, ha] at hexp
        | some a =>
          have s1 : sourceOrigin src op = some a := by simp [sourceOrigin, hleft, ha]
          rw [s1, s2, ihs, iht, drop_of_getElem? src l a ha]
          exact ⟨rfl, rfl⟩
      | some r =>
        rw [hright] at hr
        have hrj : r = j := some_eq_of_or hr
        subst hrj
        have e2 : nextRight r op = r + 1 := by simp [nextRight, hright]
        rw [e2] at iht
        rw [hleft, hright] at hexp
        cases ha : src[l]? with
        | none => simp [expected, ha] at hexp
        | some a =>
          cases hb : tgt[r]? with
          | none => simp [expected, ha, hb] at hexp
          | some b =>
            have s1 : sourceOrigin src op = some a := by simp [sourceOrigin, hleft, ha]
            have s2 : targetOrigin tgt op = some b := by simp [targetOrigin, hright, hb]
            rw [s1, s2, ihs, iht, drop_of_getElem? src l a ha, drop_of_getElem? tgt r b hb]
            exact ⟨rfl, rfl⟩

/-- Coverage. The compared actions of a replayed program read every selected
source occurrence and write every selected target occurrence exactly once, with
its type, in the selected order. None is dropped, duplicated or reordered. -/
theorem check_coverage (src tgt : List (Origin τ)) (ops : List Op)
    (h : check src tgt 0 0 ops = true) :
    consumed (nativeActions src tgt ops) = src ∧ produced (nativeActions src tgt ops) = tgt := by
  obtain ⟨hs, ht⟩ := check_reads src tgt ops 0 0 h
  rw [consumed_native, produced_native, hs, ht]
  exact ⟨rfl, rfl⟩

/-- Cross-arm correspondence. If each arm's selected native program replays on
its own authenticated orders and the two original-coordinate action lists are
equal, then the arms selected the same typed source order and the same typed
target order, and so the same kinds, charges and occurrence links in order. -/
theorem matched_native_orders (srcF tgtF srcC tgtC : List (Origin τ)) (opsF opsC : List Op)
    (hF : check srcF tgtF 0 0 opsF = true) (hC : check srcC tgtC 0 0 opsC = true)
    (h : nativeActions srcF tgtF opsF = nativeActions srcC tgtC opsC) :
    srcF = srcC ∧ tgtF = tgtC := by
  obtain ⟨fs, ft⟩ := check_coverage srcF tgtF opsF hF
  obtain ⟨cs, ct⟩ := check_coverage srcC tgtC opsC hC
  rw [h] at fs ft
  exact ⟨fs.symm.trans cs, ft.symm.trans ct⟩

/-- No altered kind or charge replays: two replayed programs over the same
orders with the same index pairs are the same program. -/
theorem check_determined (src tgt : List (Origin τ)) : ∀ (ops ops' : List Op) (i j : Nat),
    check src tgt i j ops = true → check src tgt i j ops' = true →
    ops.map (fun o => (o.left, o.right)) = ops'.map (fun o => (o.left, o.right)) → ops = ops'
  | [], [], _, _, _, _, _ => rfl
  | [], _ :: _, _, _, _, _, hm => by cases hm
  | _ :: _, [], _, _, _, _, hm => by cases hm
  | op :: rest, op' :: rest', i, j, h, h', hm => by
    have hsplit : StepOk src tgt i j op ∧
        check src tgt (nextLeft i op) (nextRight j op) rest = true := by
      simpa [check] using h
    have hsplit' : StepOk src tgt i j op' ∧
        check src tgt (nextLeft i op') (nextRight j op') rest' = true := by
      simpa [check] using h'
    obtain ⟨⟨_, _, hexp⟩, hrest⟩ := hsplit
    obtain ⟨⟨_, _, hexp'⟩, hrest'⟩ := hsplit'
    have hpair : (op.left, op.right) = (op'.left, op'.right) := (List.cons.inj hm).1
    have htail : rest.map (fun o => (o.left, o.right)) = rest'.map (fun o => (o.left, o.right)) :=
      (List.cons.inj hm).2
    have hleft : op.left = op'.left := congrArg Prod.fst hpair
    have hright : op.right = op'.right := congrArg Prod.snd hpair
    have hop : op = op' := by
      cases op with
      | mk kind cost left right =>
        cases op' with
        | mk kind' cost' left' right' =>
          have hl : left = left' := hleft
          have hr : right = right' := hright
          subst hl; subst hr
          have e : expected src tgt left right = some (kind, cost) := hexp
          have e' : expected src tgt left right = some (kind', cost') := hexp'
          rw [e] at e'
          have pair : (kind, cost) = (kind', cost') := Option.some.inj e'
          have hk : kind = kind' := congrArg Prod.fst pair
          have hc : cost = cost' := congrArg Prod.snd pair
          subst hk; subst hc
          rfl
    subst hop
    rw [check_determined src tgt rest rest' (nextLeft i op) (nextRight j op) hrest hrest' htail]

/-- The immutable selection. A supplied program is the selected one only when
it is the retained one; replaying and costing the same are not enough. -/
def selectionBound (retained supplied : List Op) : Bool := decide (supplied = retained)

theorem selectionBound_iff (retained supplied : List Op) :
    selectionBound retained supplied = true ↔ supplied = retained := by
  simp [selectionBound]

end Program

/-! ## Part 3. Failure provenance -/

/-- How a comparison attempt can fail to produce a verdict. -/
inductive Fault where
  | budget
  | unsupported (reason : String)
  | replayCheck (reason : String)
  | internal (boundary : String)

inductive Conclusion where
  | matched
  | mismatch
  | uncheckable (reason : String)
  | invalidReplay (reason : String)
  | internalError (boundary : String)

/-- A failed explicit replay check demonstrates an invalid native replay. Any
other execution error of the consumer is an internal error. -/
def classify : Fault → Conclusion
  | .budget => .uncheckable "REPLAY_BUDGET"
  | .unsupported reason => .uncheckable reason
  | .replayCheck reason => .invalidReplay reason
  | .internal boundary => .internalError boundary

def fatal : Conclusion → Bool
  | .invalidReplay _ => true
  | .internalError _ => true
  | .matched => false
  | .mismatch => false
  | .uncheckable _ => false

theorem classify_never_matched (f : Fault) : classify f ≠ Conclusion.matched := by
  cases f <;> intro h <;> cases h

theorem classify_never_mismatch (f : Fault) : classify f ≠ Conclusion.mismatch := by
  cases f <;> intro h <;> cases h

theorem internal_not_invalid_replay (boundary reason : String) :
    classify (Fault.internal boundary) ≠ Conclusion.invalidReplay reason := by
  intro h; cases h

theorem replay_check_not_internal (reason boundary : String) :
    classify (Fault.replayCheck reason) ≠ Conclusion.internalError boundary := by
  intro h; cases h

theorem internal_not_uncheckable (boundary reason : String) :
    classify (Fault.internal boundary) ≠ Conclusion.uncheckable reason := by
  intro h; cases h

theorem replay_check_not_uncheckable (reason reason' : String) :
    classify (Fault.replayCheck reason) ≠ Conclusion.uncheckable reason' := by
  intro h; cases h

theorem internal_fatal (boundary : String) : fatal (classify (Fault.internal boundary)) = true := rfl

theorem replay_check_fatal (reason : String) :
    fatal (classify (Fault.replayCheck reason)) = true := rfl

/-- Every refusal is explained: it is the budget refusal or carries the reason
of an explicit correspondence refusal. -/
theorem uncheckable_explained (f : Fault) (reason : String)
    (h : classify f = Conclusion.uncheckable reason) :
    (f = Fault.budget ∧ reason = "REPLAY_BUDGET") ∨ f = Fault.unsupported reason := by
  cases f with
  | budget =>
    have hr : Conclusion.uncheckable "REPLAY_BUDGET" = Conclusion.uncheckable reason := h
    exact Or.inl ⟨rfl, (Conclusion.uncheckable.inj hr).symm⟩
  | unsupported r =>
    have hr : Conclusion.uncheckable r = Conclusion.uncheckable reason := h
    rw [Conclusion.uncheckable.inj hr]
    exact Or.inr rfl
  | replayCheck r => cases h
  | internal b => cases h

/-- A conclusion keeps the native receipts it was reached with, and an internal
error keeps its earliest failing boundary. -/
structure Verdict (ρ : Type) where
  conclusion : Conclusion
  receipt : ρ

def conclude {ρ : Type} (receipt : ρ) (f : Fault) : Verdict ρ := ⟨classify f, receipt⟩

theorem conclude_retains_receipt {ρ : Type} (receipt : ρ) (f : Fault) :
    (conclude receipt f).receipt = receipt := rfl

theorem conclude_internal_boundary {ρ : Type} (receipt : ρ) (boundary : String) :
    (conclude receipt (Fault.internal boundary)).conclusion =
      Conclusion.internalError boundary := rfl

/-- The batch policy: ordinary discrepancies and refusals are retained and the
batch continues; an invalid replay or an internal error stops it. -/
def batchContinues (c : Conclusion) : Bool := !fatal c

theorem batch_retains_ordinary (reason : String) :
    batchContinues Conclusion.matched = true ∧ batchContinues Conclusion.mismatch = true ∧
      batchContinues (Conclusion.uncheckable reason) = true := ⟨rfl, rfl, rfl⟩

theorem batch_stops_on_fault (f : Fault) (h : fatal (classify f) = true) :
    batchContinues (classify f) = false := by
  simp [batchContinues, h]

end ACGN.FifthFive.SharedActionBoundary
