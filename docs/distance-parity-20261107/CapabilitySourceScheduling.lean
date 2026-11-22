import Phase5SourceRules
import UnusedGroupedBindings
import TemporalPhaseLocalBinding

namespace CapabilitySourceScheduling

/- Source rules run with no assumed binding facts before liveness analysis.
The existing typed-rule premises still apply; this changes their schedule,
not the available equations or the later certificate ACI boundary. -/

-- Pointwise rewriting leaves every typed environment, owner and domain fixed.
theorem contextual_congruence {Env Value : Type}
    (before after : Env → Value → Prop)
    (equivalent : ∀ env value, before env value ↔ after env value)
    (context : (Env → Value → Prop) → Prop) :
    context before ↔ context after := by
  have same : before = after := funext fun env =>
    funext fun value => propext (equivalent env value)
  rw [same]

-- Grouped or dependent declarations are admissible assignments, not an
-- assumption that any carrier is inhabited. Their domain is never erased.
theorem existential_contradiction {Assignment : Type}
    (domain body : Assignment → Prop) (outside : Prop) :
    ((∃ assignment, domain assignment ∧ body assignment) ∧
      (outside ∧ ¬ outside)) ↔ False := by
  simp

theorem prenex_contradiction {Assignment : Type}
    (domain body : Assignment → Prop) (outside : Prop) :
    (∃ assignment, (domain assignment ∧ body assignment) ∧
      (outside ∧ ¬ outside)) ↔ False := by
  exact (safe_exists_conjunction_prenex
    (fun assignment => domain assignment ∧ body assignment)
    (outside ∧ ¬ outside)).symm.trans
      (existential_contradiction domain body outside)

theorem negated_prenex_contradiction {Assignment : Type}
    (domain body : Assignment → Prop) (outside : Prop) :
    (¬ ∃ assignment, (domain assignment ∧ body assignment) ∧
      (outside ∧ ¬ outside)) ↔ True := by
  rw [prenex_contradiction]
  simp

theorem guarded_universal_tautology {Assignment : Type}
    (domain : Assignment → Prop) (outside : Prop) :
    (∀ assignment, domain assignment → (outside ∨ ¬ outside)) ↔ True :=
  UnusedGroupedBindings.all_after_tautology domain (fun _ => outside)

-- The bound slot and opaque CALL remain arbitrary. The folded atom is the
-- typed relation law A subset (A union B), not a guessed CALL result.
theorem typed_subset_atom {Atom : Type} (a b : Rel Atom) :
    subset a (union a b) ↔ True :=
  ⟨fun _ => True.intro, fun _ => subset_union_left a b⟩

theorem typed_subset_negation {Atom : Type} (a b : Rel Atom) :
    (¬ subset a (union a b)) ↔ False := by
  rw [typed_subset_atom]
  simp

theorem no_all_source_pair {Value Atom : Type}
    (a b : Rel Atom) (domain body : Value → Prop)
    (opaqueCall nonempty : Prop) :
    (¬ ∃ value, domain value ∧ (body value ∧ opaqueCall ∧
      (subset a (union a b) ∨ ¬ nonempty) ∧ nonempty)) ↔
    (∀ value, domain value → ¬ (body value ∧ opaqueCall ∧ nonempty)) := by
  classical
  simp only [typed_subset_atom, true_or, true_and]
  simp

theorem quantifier_negation_source_pair {Value Atom : Type}
    (a b : Rel Atom) (domain body : Value → Prop)
    (opaqueCall relationNonempty carrierNonempty : Prop) :
    (¬ ∀ value, domain value → (body value ∧ opaqueCall ∧
      ((relationNonempty ∧ subset a (union a b)) ∨ carrierNonempty))) ↔
    (∃ value, domain value ∧ ¬ (body value ∧ opaqueCall ∧
      (relationNonempty ∨ carrierNonempty))) := by
  classical
  simp only [typed_subset_atom, and_true]
  simp

-- A same-typed grouped pair is instantiated without an inhabitation premise;
-- swapping the two bound coordinates does not change the contradiction.
theorem grouped_prenex_source_pair {Atom : Type}
    (domain : Atom → Prop) (edge : Atom → Atom → Prop)
    (opaqueCall : Prop) :
    (((∃ x y, domain x ∧ domain y ∧ edge x y) ∧
      (opaqueCall ∧ ¬ relNonempty domain ∧ relNonempty domain)) ↔ False) ∧
    ((∃ y x, domain y ∧ domain x ∧ edge x y ∧
      (opaqueCall ∧ ¬ relNonempty domain ∧ relNonempty domain)) ↔ False) := by
  simp

-- These counterexamples continue to forbid dropping a last unused slot
-- without its existence guard, or forgetting a declaration's disjointness.
theorem empty_domain_guard_retained :
    (∀ value : Empty, False) ∧ ¬ (∃ _value : Empty, True) :=
  ⟨UnusedGroupedBindings.empty_all_counterexample.1,
    UnusedGroupedBindings.empty_some_counterexample.1⟩

theorem disjoint_declarations_retained :
    ¬ (∃ x y : Unit, x ≠ y ∧ True) ∧ (∃ _x : Unit, True) :=
  UnusedGroupedBindings.disjoint_counterexample

-- A declaration's multiplicity constrains relation-valued assignments. It is
-- not a Boolean cardinality expression, even when it shares the ONE/LONE tag.
theorem empty_one_declaration {Atom : Type} (candidate : Rel Atom) :
    ¬ admits .one noneRel candidate := one_none_has_no_binding candidate

theorem empty_lone_declaration {Atom : Type} (candidate : Rel Atom) :
    admits .lone noneRel candidate ↔ candidate = noneRel :=
  lone_none_exactly_one_binding candidate

theorem empty_set_declaration {Atom : Type} (candidate : Rel Atom) :
    admits .set noneRel candidate ↔ candidate = noneRel :=
  set_none_exactly_one_binding candidate

theorem admitted_nonempty_cardinality {Atom : Type}
    (multiplicity : Multiplicity) (domain value : Rel Atom)
    (positive : multiplicity = .one ∨ multiplicity = .some)
    (binding : admits multiplicity domain value) :
    (relNonempty value ↔ True) ∧ ((¬ relNonempty value) ↔ False) := by
  have nonempty : relNonempty value := by
    rcases positive with rfl | rfl
    · exact binding.2.1
    · exact binding.2
  exact ⟨⟨fun _ => True.intro, fun _ => nonempty⟩,
    ⟨fun denied => denied nonempty, False.elim⟩⟩

theorem guarded_nested_negation_tautology {Value : Type}
    (domain : Value → Prop) (p q : Prop) :
    (∀ value, domain value → (¬ ¬ p ∨ q ∨ ¬ p)) ↔ True := by
  classical
  by_cases h : p <;> simp [h]

-- Body equivalence is contextual only when the observable interface is kept.
-- In particular, simplifying both bodies to True cannot erase a carrier edit.
theorem interface_body_congruence {Signature : Type} (signature : Signature)
    (before after : Prop) (equivalent : before ↔ after) :
    (signature, before) = (signature, after) := by
  rw [propext equivalent]

theorem distinct_interfaces_retained {Signature : Type} (left right : Signature)
    (distinct : left ≠ right) : (left, True) ≠ (right, True) := by
  intro same
  exact distinct (congrArg Prod.fst same)

theorem distinct_interface_witness : (0, True) ≠ (1, True) :=
  distinct_interfaces_retained 0 1 (by decide)

-- Missing exact-type evidence cannot authenticate a declaration-guard alias.
theorem missing_type_cannot_authenticate {ExactType : Type}
    (observed : Option ExactType) :
    ¬ ∃ exact, (none : Option ExactType) = some exact ∧ observed = some exact := by
  simp

theorem snapshot_guard_precedes_source_absorption :
    TemporalPhaseLocalBinding.carrierAbsorptionAdmitted true true = false :=
  TemporalPhaseLocalBinding.imported_snapshot_rejects_mutable_carrier_absorption

theorem static_snapshot_absorption_retained :
    TemporalPhaseLocalBinding.carrierAbsorptionAdmitted true false = true :=
  TemporalPhaseLocalBinding.imported_snapshot_retains_static_carrier_absorption

-- Eliminate a checked membership binder before distributing its body. Both
-- schedules denote the same formula, including when the carrier is empty.
theorem membership_before_distribution {Atom : Type}
    (domain left right : Rel Atom) :
    (∀ candidate, admits .one domain candidate →
      ¬ subset candidate (intersection left right)) ↔
      ¬ relNonempty (intersection domain (intersection left right)) :=
  all_one_negative_membership_iff_intersection_empty domain (intersection left right)

theorem distributed_membership_route {Atom : Type}
    (domain left right : Rel Atom) :
    (∀ atom, domain atom → (¬ left atom ∨ ¬ right atom)) ↔
      ¬ relNonempty (intersection domain (intersection left right)) := by
  classical
  constructor
  · intro allAtoms ⟨atom, inDomain, inLeft, inRight⟩
    rcases allAtoms atom inDomain with absent | absent
    · exact absent inLeft
    · exact absent inRight
  · intro emptyIntersection atom inDomain
    by_cases inLeft : left atom
    · exact Or.inr (fun inRight => emptyIntersection ⟨atom, inDomain, inLeft, inRight⟩)
    · exact Or.inl inLeft

theorem subcarrier_membership_elimination {Atom : Type}
    (domain target : Rel Atom) (typedCarrier : subset target domain) :
    (∀ candidate, admits .one domain candidate → ¬ subset candidate target) ↔
      ¬ relNonempty target := by
  rw [all_one_negative_membership_iff_intersection_empty]
  have same : intersection domain target = target := by
    funext atom
    apply propext
    exact ⟨fun h => h.2, fun h => ⟨typedCarrier atom h, h⟩⟩
  rw [same]

-- A tautological sibling must be removed before deciding whether its other
-- sibling can lift. This does not assert that the quantified domain is inhabited.
theorem restriction_universal_neutral {Value Atom : Type}
    (domain : Value → Prop) (restrictor : Value → Rel Atom)
    (target : Rel Atom) (body : Prop) :
    (body ∧ ∀ value, domain value →
      subset (unaryDomainRestriction (restrictor value) target) target) ↔ body := by
  constructor
  · exact And.left
  · intro holds
    exact ⟨holds, fun _ _ _ member => member.2⟩

theorem membership_multiplicity_guards_retained {Atom : Type}
    (domain target : Rel Atom) :
    (¬ ∀ candidate, admits .set domain candidate → ¬ subset candidate target) ∧
    (¬ ∀ candidate, admits .lone domain candidate → ¬ subset candidate target) :=
  ⟨all_set_negative_membership_is_false domain target,
    all_lone_negative_membership_is_false domain target⟩

end CapabilitySourceScheduling
