import Std

/- Arithmetic specification for the bounded performance grid. This proves the
   allocation bounds, not Python's PRNG, Alloy parsing, or runtime behavior. -/
namespace BalancedGrid

def load (n m : Nat) (extra : Bool) : Nat := n / m + if extra then 1 else 0

theorem allocation_total (n m : Nat) : (n / m) * m + n % m = n := by
  simpa [Nat.mul_comm] using Nat.div_add_mod n m

theorem each_type_inhabited (n m : Nat) (extra : Bool)
    (hm : 0 < m) (hmn : m ≤ n) : 1 ≤ load n m extra := by
  have h := Nat.div_pos hmn hm
  unfold load
  split <;> omega

theorem balanced (n m : Nat) (a b : Bool) : load n m a ≤ load n m b + 1 := by
  unfold load
  split <;> split <;> omega

theorem remainder_fits (n m : Nat) (hm : 0 < m) : n % m < m := Nat.mod_lt n hm

theorem bounded_grid (n m : Nat) (hn : n ≤ 10) (hm : m ≤ n) : m ≤ 10 := by
  omega

#print axioms allocation_total
#print axioms each_type_inhabited
#print axioms balanced
#print axioms remainder_fits
#print axioms bounded_grid
end BalancedGrid
