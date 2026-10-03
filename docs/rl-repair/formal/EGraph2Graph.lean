import Std

namespace RepairTransformer

structure Port where
  source : Nat
  target : Nat
  kind : String
  position : Nat
  deriving BEq, DecidableEq, Repr

structure Request where
  nodes : Nat
  edges : List Port
  actions : List Nat
  allowed : List Bool
  width : Nat
  heads : Nat
  layers : Nat
  slots : Nat
  deriving BEq, DecidableEq, Repr

def Valid (r : Request) : Prop :=
  0 < r.nodes ∧ r.nodes ≤ 4096 ∧ r.edges.length ≤ 65536 ∧
  (∀ e ∈ r.edges, e.source < r.nodes ∧ e.target < r.nodes) ∧
  0 < r.actions.length ∧ r.actions.length ≤ 512 ∧
  (∀ a ∈ r.actions, a < r.nodes) ∧
  r.allowed.length = r.actions.length ∧ true ∈ r.allowed ∧
  8 ≤ r.width ∧ r.width ≤ 16384 ∧ 0 < r.heads ∧ r.heads ≤ 16 ∧
  r.width % r.heads = 0 ∧ 0 < r.layers ∧ r.layers ≤ 8 ∧ r.slots = 8

instance (r : Request) : Decidable (Valid r) := inferInstanceAs (Decidable (_ ∧ _))
def admitted (r : Request) : Bool := decide (Valid r)

theorem admission_valid (r : Request) (h : admitted r = true) : Valid r := by
  simpa [admitted] using h
theorem rejection_invalid (r : Request) (h : ¬Valid r) : admitted r = false := by
  simp [admitted, h]
theorem admitted_node_bounds (r : Request) (h : Valid r) : 0 < r.nodes ∧ r.nodes ≤ 4096 :=
  ⟨h.1, h.2.1⟩
theorem admitted_endpoints (r : Request) (h : Valid r) (e : Port) (he : e ∈ r.edges) :
    e.source < r.nodes ∧ e.target < r.nodes := h.2.2.2.1 e he
theorem admitted_action_pointer (r : Request) (h : Valid r) (a : Nat) (ha : a ∈ r.actions) :
    a < r.nodes := h.2.2.2.2.2.2.1 a ha
theorem admitted_head_partition (r : Request) (h : Valid r) :
    (r.width / r.heads) * r.heads = r.width := by
  have hm : r.width % r.heads = 0 := h.2.2.2.2.2.2.2.2.2.2.2.2.2.1
  have equation := Nat.mod_add_div r.width r.heads
  rw [hm, Nat.zero_add, Nat.mul_comm] at equation
  exact equation

def relabel (f : Nat → Nat) (e : Port) : Port :=
  {e with source := f e.source, target := f e.target}
theorem relabel_port_attributes (f : Nat → Nat) (e : Port) :
    (relabel f e).kind = e.kind ∧ (relabel f e).position = e.position := ⟨rfl, rfl⟩
theorem relabel_duplicate_ports (f : Nat → Nat) (e : Port) :
    [e, e].map (relabel f) = [relabel f e, relabel f e] := rfl
theorem relabel_pointer (f : Nat → Nat) (xs : List Nat) (i : Fin xs.length) :
    (xs.map f)[i.val]'(by simp) = f (xs[i.val]) := by simp

/- Integer weighted moments specify the algebra, not floating-point softmax. -/
def mass (xs : List α) (weight : α → Nat) : Nat := (xs.map weight).sum
def moment (xs : List α) (weight : α → Nat) (value : α → Int) : Int :=
  (xs.map fun x => (weight x : Int) * value x).sum
theorem mass_order_invariant (a b : List α) (p : a.Perm b) (w : α → Nat) :
    mass a w = mass b w := (p.map w).sum_nat
theorem moment_order_invariant (a b : List α) (p : a.Perm b) (w : α → Nat) (v : α → Int) :
    moment a w v = moment b w v := by
  exact (p.map _).foldr_eq' (by intros; omega) 0
theorem positive_mass (xs : List α) (w : α → Nat) (h : ∃ x ∈ xs, 0 < w x) :
    0 < mass xs w := by
  apply List.sum_pos_iff_exists_pos_nat.mpr
  obtain ⟨x, hx, hp⟩ := h
  exact ⟨w x, List.mem_map.mpr ⟨x, hx, rfl⟩, hp⟩
theorem duplicate_mass_retained (x : α) (xs : List α) (w : α → Nat) :
    mass (x :: x :: xs) w = w x + w x + mass xs w := by simp [mass, Nat.add_assoc]
theorem cross_read_permutation (a b : List α) (p : a.Perm b)
    (queries : List β) (w : β → α → Nat) (v : α → Int) :
    queries.map (fun q => (mass a (w q), moment a (w q) v)) =
    queries.map (fun q => (mass b (w q), moment b (w q) v)) := by
  apply List.map_congr_left
  intro q _
  rw [mass_order_invariant a b p, moment_order_invariant a b p]
theorem query_order_equivariant (read : β → α) (a b : List β) (p : a.Perm b) :
    (a.map read).Perm (b.map read) := p.map read
theorem pointwise_composition (a : List α) (f : α → β) (g : β → γ) :
    (a.map f).map g = a.map (g ∘ f) := List.map_map

def masked (allowed : Bool) (weight : Nat) := if allowed then weight else 0
theorem masked_zero (w : Nat) : masked false w = 0 := rfl
theorem positive_mask_is_allowed (a : Bool) (w : Nat) (h : 0 < masked a w) : a = true := by
  cases a <;> simp_all [masked]

universe u
variable {α : Type u} {P : α → Prop}

def commit (old : {g : α // P g}) (candidate : Option {g : α // P g}) : {g : α // P g} :=
  candidate.getD old
theorem commit_requires_checked_graph (old : {g : α // P g}) (candidate : Option {g : α // P g}) :
    P (commit old candidate).val := (commit old candidate).property
theorem rejected_preserves_graph (old : {g : α // P g}) : commit old none = old := rfl
theorem accepted_uses_checked_graph (old next : {g : α // P g}) : commit old (some next) = next := rfl

def parameters (w d : Nat) := 11 * w * w + 4189 * w + 2 + d * (18 * w * w + 25 * w)
theorem layer_parameter_increment (w d : Nat) :
    parameters w (d + 1) = parameters w d + (18 * w * w + 25 * w) := by
  simp [parameters, Nat.add_mul, Nat.add_assoc]
def globalPairs (n slots : Nat) := 2 * n * slots
theorem fixed_latents_linear (n : Nat) : globalPairs n 8 = 16 * n := by
  simp [globalPairs]; omega

end RepairTransformer
