import Std

namespace RepairGraphs

structure Edge (n : Nat) where
  source : Fin n
  target : Fin n
  kind : Nat
  position : Nat
  backward : Bool := false
  deriving DecidableEq, BEq, Repr

def reverse (e : Edge n) : Edge n :=
  { e with source := e.target, target := e.source, backward := !e.backward }

def bidirectional (es : List (Edge n)) : List (Edge n) :=
  es.flatMap (fun e => [e, reverse e])

def selfEdge (v : Fin n) : Edge n := ⟨v, v, 0, 0, false⟩
def selfEdges (n : Nat) : List (Edge n) := (List.finRange n).map selfEdge
def withSelf (es : List (Edge n)) : List (Edge n) := bidirectional es ++ selfEdges n
def incoming (v : Fin n) (es : List (Edge n)) : List (Edge n) :=
  es.filter (fun e => e.target == v)
def degree (v : Fin n) (es : List (Edge n)) : Nat := (incoming v es).length

theorem endpoint_bounds (e : Edge n) : e.source.val < n ∧ e.target.val < n :=
  ⟨e.source.isLt, e.target.isLt⟩
theorem reverse_attributes (e : Edge n) :
    (reverse e).kind = e.kind ∧ (reverse e).position = e.position := ⟨rfl, rfl⟩
theorem reverse_twice (e : Edge n) : reverse (reverse e) = e := by
  cases e; simp [reverse]
theorem bidirectional_count (es : List (Edge n)) :
    (bidirectional es).length = 2 * es.length := by
  induction es with
  | nil => rfl
  | cons e es ih =>
    change ([e, reverse e] ++ bidirectional es).length = 2 * (es.length + 1)
    simp only [List.length_append, List.length_cons, List.length_nil, ih]
    omega
theorem self_edge_count (n : Nat) : (selfEdges n).length = n := by simp [selfEdges]
theorem with_self_count (es : List (Edge n)) :
    (withSelf es).length = 2 * es.length + n := by
  simp [withSelf, bidirectional_count, self_edge_count]
theorem duplicate_occurrences_retained (e : Edge n) :
    bidirectional [e, e] = [e, reverse e, e, reverse e] := rfl
theorem self_is_incoming (v : Fin n) (es : List (Edge n)) :
    selfEdge v ∈ incoming v (withSelf es) := by
  simp only [incoming, List.mem_filter, withSelf, List.mem_append]
  constructor
  · exact Or.inr (List.mem_map.mpr ⟨v, List.mem_finRange v, rfl⟩)
  · simp [selfEdge]
theorem self_degree_positive (v : Fin n) (es : List (Edge n)) :
    0 < degree v (withSelf es) := List.length_pos_of_mem (self_is_incoming v es)
theorem gcn_degree_product_positive (a b : Fin n) (es : List (Edge n)) :
    0 < degree a (withSelf es) * degree b (withSelf es) :=
  Nat.mul_pos (self_degree_positive a es) (self_degree_positive b es)

def aggregate (v : Fin n) (es : List (Edge n)) (message : Edge n -> Int) : Int :=
  ((incoming v es).map message).sum

theorem degree_edge_order_invariant (v : Fin n) (a b : List (Edge n)) (p : a.Perm b) :
    degree v a = degree v b := (p.filter _).length_eq
theorem aggregate_edge_order_invariant (v : Fin n) (a b : List (Edge n))
    (p : a.Perm b) (message : Edge n -> Int) : aggregate v a message = aggregate v b message := by
  exact ((p.filter _).map message).foldr_eq' (by intros; omega) 0
theorem aggregate_duplicate (v : Fin n) (e : Edge n) (es : List (Edge n))
    (target : e.target = v) (message : Edge n -> Int) :
    aggregate v (e :: e :: es) message = message e + message e + aggregate v es message := by
  simp [aggregate, incoming, target, Int.add_assoc]

def relabel (f : Fin n -> Fin n) (e : Edge n) : Edge n :=
  { e with source := f e.source, target := f e.target }
theorem relabel_attributes (f : Fin n -> Fin n) (e : Edge n) :
    (relabel f e).kind = e.kind ∧ (relabel f e).position = e.position := ⟨rfl, rfl⟩
theorem relabel_reverse (f : Fin n -> Fin n) (e : Edge n) :
    relabel f (reverse e) = reverse (relabel f e) := rfl
theorem relabel_incoming (f : Fin n -> Fin n) (injective : ∀ a b, f a = f b → a = b)
    (v : Fin n) (es : List (Edge n)) :
    incoming (f v) (es.map (relabel f)) = (incoming v es).map (relabel f) := by
  induction es with
  | nil => rfl
  | cons e es ih =>
    by_cases h : e.target = v
    · have hf := congrArg f h
      simpa [incoming, List.filter_cons, relabel, h, hf] using congrArg (List.cons (relabel f e)) ih
    · have hf : f e.target ≠ f v := fun bad => h (injective _ _ bad)
      simpa [incoming, List.filter_cons, relabel, h, hf] using ih

/- Exact numerator/denominator contract for normalized nonnegative weights. The
   real exponential and floating-point evaluation are external numerical work. -/
structure AttentionWeights where
  numerators : List Nat
  positiveWitness : ∃ x ∈ numerators, 0 < x

def denominator (w : AttentionWeights) : Nat := w.numerators.sum
theorem attention_denominator_positive (w : AttentionWeights) : 0 < denominator w :=
  List.sum_pos_iff_exists_pos_nat.mpr w.positiveWitness
theorem attention_mass_numerator (w : AttentionWeights) :
    w.numerators.sum = denominator w := rfl
theorem attention_denominator_order_invariant (a b : AttentionWeights)
    (p : a.numerators.Perm b.numerators) : denominator a = denominator b := p.sum_nat

inductive Encoder where
  | mpnn | gcn | gat | gin
  deriving DecidableEq, BEq
structure Architecture where
  encoder : Encoder
  hidden : Nat
  layers : Nat
  heads : Nat
  graphContractHash : String
  deriving DecidableEq, BEq
def ValidArchitecture (a : Architecture) : Prop :=
  0 < a.hidden ∧ 0 < a.layers ∧ 0 < a.heads ∧
  (a.encoder = .gat → a.hidden % a.heads = 0) ∧ (a.encoder ≠ .gat → a.heads = 1)
theorem gat_head_width_reconstructs (a : Architecture) (h : ValidArchitecture a)
    (gat : a.encoder = .gat) : (a.hidden / a.heads) * a.heads = a.hidden := by
  have equation := Nat.mod_add_div a.hidden a.heads
  rw [h.2.2.2.1 gat, Nat.zero_add, Nat.mul_comm] at equation
  exact equation
theorem same_architecture_keeps_encoder (a b : Architecture) (h : decide (a = b) = true) :
    a.encoder = b.encoder := by
  have eq : a = b := by simpa using h
  exact congrArg Architecture.encoder eq

end RepairGraphs

open RepairGraphs

def main : IO Unit := do
  for n in [1, 2, 3, 4] do
    for s in List.finRange n do
      for t in List.finRange n do
        for duplicate in [false, true] do
          for loops in [false, true] do
            let e : Edge n := ⟨s, t, 1, 2, false⟩
            let es := if duplicate then [e, e] else [e]
            let messages := if loops then withSelf es else bidirectional es
            for v in List.finRange n do
              let value := aggregate v messages (fun e =>
                Int.ofNat ((e.source.val + 1) * 10 + e.kind * 2 + (if e.backward then 1 else 0) + e.position))
              IO.println s!"GRAPH,{n},{s.val},{t.val},{duplicate},{loops},{v.val},{degree v messages},{value}"
