import Std

namespace RepairCapacity

inductive Family where
  | mpnn | gcn | gat | gin | egraph_transformer
  deriving Repr, BEq, DecidableEq

def base (width : Nat) : Nat := 5 * width * width + 4182 * width + 2
def perLayer (family : Family) (width : Nat) : Nat :=
  match family with
  | .mpnn => 8 * width * width + 9 * width
  | .gcn => 2 * width * width + 2 * width
  | .gat => 2 * width * width + 5 * width
  | .gin => 5 * width * width + 5 * width + 1
  | .egraph_transformer => 18 * width * width + 25 * width

def extra (family : Family) (width : Nat) : Nat :=
  if family == .egraph_transformer then 6 * width * width + 7 * width else 0

def parameters (family : Family) (width depth : Nat) : Nat :=
  base width + extra family width + depth * perLayer family width

theorem shared_parameters_present (f : Family) (w d : Nat) :
    base w ≤ parameters f w d := by unfold parameters; omega

theorem layer_increment (f : Family) (w d : Nat) :
    parameters f w (d + 1) = parameters f w d + perLayer f w := by
  simp [parameters, Nat.add_mul, Nat.add_assoc]

theorem depth_monotone (f : Family) (w a b : Nat) (h : a ≤ b) :
    parameters f w a ≤ parameters f w b := by
  exact Nat.add_le_add_left (Nat.mul_le_mul_right _ h) _

def fp32ParameterBytes (f : Family) (w d : Nat) : Nat := 4 * parameters f w d
def nominalAdamBytes (f : Family) (w d : Nat) : Nat := 16 * parameters f w d

theorem nominal_four_full_tensors (f : Family) (w d : Nat) :
    nominalAdamBytes f w d = 4 * fp32ParameterBytes f w d := by
  simp only [nominalAdamBytes, fp32ParameterBytes]
  omega

/- Composition allows distinct learned parameters at every layer. -/
theorem distinct_layers_preserve (property : α → Prop) (layers : List (α → α))
    (closed : ∀ layer ∈ layers, ∀ x, property x → property (layer x))
    (x : α) (h : property x) : property (layers.foldl (fun state layer => layer state) x) := by
  induction layers generalizing x with
  | nil => exact h
  | cons layer rest ih =>
    apply ih
    · intro f hf y hy
      exact closed f (List.mem_cons_of_mem layer hf) y hy
    · exact closed layer (by simp) x h

end RepairCapacity

open RepairCapacity

def main : IO Unit := do
  for (family, name) in [(Family.mpnn, "mpnn"), (.gcn, "gcn"), (.gat, "gat"), (.gin, "gin"), (.egraph_transformer, "egraph_transformer")] do
    for width in [8, 32, 64, 96, 256, 512, 1024, 2048, 4096, 8192, 16384] do
      for depth in [1, 2, 4, 6, 8] do
        IO.println s!"CAPACITY,{name},{width},{depth},{parameters family width depth},{fp32ParameterBytes family width depth},{nominalAdamBytes family width depth}"
