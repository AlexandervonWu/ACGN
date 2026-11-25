import AdaptiveRoleSupport
import AdaptiveCardinality

namespace AdaptiveRoleCounting
open AdaptiveRoleSupport AdaptiveCardinality

-- Each row is a set of distinct targets. The effective cap bounds the whole
-- target carrier, not the number of owners or the size of a sampled row.
structure Rows (w : World α β) (cap : Nat) where
  carrier : List β
  bound : carrier.length ≤ cap
  row : α → List β
  unique : ∀ x, (row x).Nodup
  read : ∀ x y, y ∈ row x ↔ w.edge x y
  covers : ∀ x, row x ⊆ carrier

theorem row_test (w : World α β) (rows : Rows w cap) (x : α) (op : Comparison)
    (wide : 2 < 2^width) (guard : safeAt op width cap) :
    counted op width (rows.row x).length ↔ multiplicity op (w.edge x) :=
  rewrite_iff op width cap wide _ _ (rows.unique x) (rows.read x)
    (Nat.le_trans ((rows.unique x).length_le_of_subset (rows.covers x)) rows.bound) guard

theorem positive_roles (w : World α β) (rows : Rows w cap)
    (wide : 2 < 2^width) (safe : 2*cap < 2^width) :
    (∀ x, counted .gtZero width (rows.row x).length → w.role x = true) ↔ allowed w := by
  rw [← occupied_rows]
  exact ⟨fun h x hx => h x ((row_test w rows x .gtZero wide safe).mpr hx),
         fun h x hx => h x ((row_test w rows x .gtZero wide safe).mp hx)⟩

theorem empty_nonroles (w : World α β) (rows : Rows w cap)
    (wide : 2 < 2^width) (safe : cap < 2^width) :
    (∀ x, w.role x = false → counted .eqZero width (rows.row x).length) ↔ allowed w := by
  rw [allowed_iff]
  constructor
  · intro h x y edge
    cases hr : w.role x with
    | true => rfl
    | false => exact ((row_test w rows x .eqZero wide safe).mp (h x hr) ⟨y,edge⟩).elim
  · exact fun h x hr => (row_test w rows x .eqZero wide safe).mpr
      (fun ⟨y,e⟩ => Bool.noConfusion (hr.symm.trans (h x y e)))

end AdaptiveRoleCounting
