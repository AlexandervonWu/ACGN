import Std

namespace ACGN.ContainerReplay

/- Slot numbers are injective names for complete typed Java OnePort values in
   one fixed context. The probe checks that decoding uses actual port equality.
   This checker establishes a container quotient, not source Alloy semantics. -/
inductive Kind where
  | seq | bag | set
  deriving DecidableEq, Repr

structure Trace where
  kind : Kind
  input : List Nat
  output : List Nat
  fibers : List (List Nat)
  deriving Repr

def sameSupport (input output : List Nat) : Bool :=
  input.all (fun x => output.contains x) &&
  output.all (fun x => input.contains x)

def quotientValid (t : Trace) : Bool :=
  match t.kind with
  | .seq => t.input == t.output
  | .bag => decide (t.input.Perm t.output)
  | .set => sameSupport t.input t.output && decide t.output.Nodup

def fibersValid (t : Trace) : Bool :=
  t.fibers.length == t.output.length &&
  decide (t.fibers.flatten.Perm (List.range t.input.length)) &&
  (t.output.zip t.fibers).all (fun (value, fiber) =>
    !fiber.isEmpty && fiber.all (fun i => t.input[i]? == some value)) &&
  (t.kind == .set || t.fibers.all (fun fiber => fiber.length == 1)) &&
  (t.kind != .seq || t.fibers == (List.range t.input.length).map (fun i => [i]))

def valid (t : Trace) : Bool := quotientValid t && fibersValid t

theorem valid_parts (t : Trace) (h : valid t = true) :
    quotientValid t = true ∧ fibersValid t = true := by
  simpa [valid] using h

theorem sameSupport_iff (input output : List Nat) :
    sameSupport input output = true ↔ (∀ x, x ∈ input ↔ x ∈ output) := by
  simp only [sameSupport, Bool.and_eq_true, List.all_eq_true, List.contains_iff_mem]
  constructor
  · rintro ⟨forward, backward⟩ x
    exact ⟨forward x, backward x⟩
  · intro h
    exact ⟨fun x hx => (h x).mp hx, fun x hx => (h x).mpr hx⟩

theorem sequence_preserves_order (t : Trace)
    (accepted : valid t = true) (kind : t.kind = .seq) :
    t.input = t.output := by
  have h := (valid_parts t accepted).1
  simpa [quotientValid, kind] using h

theorem bag_preserves_multiplicity (t : Trace)
    (accepted : valid t = true) (kind : t.kind = .bag) :
    ∀ value, t.input.count value = t.output.count value := by
  have h := (valid_parts t accepted).1
  have permutation : t.input.Perm t.output := by
    simpa [quotientValid, kind] using h
  exact fun value => permutation.count_eq value

theorem set_preserves_support (t : Trace)
    (accepted : valid t = true) (kind : t.kind = .set) :
    ∀ value, value ∈ t.input ↔ value ∈ t.output := by
  have h := (valid_parts t accepted).1
  have support := (show sameSupport t.input t.output = true ∧ t.output.Nodup from by
    simpa [quotientValid, kind] using h).1
  exact (sameSupport_iff _ _).mp support

theorem set_has_no_duplicates (t : Trace)
    (accepted : valid t = true) (kind : t.kind = .set) : t.output.Nodup := by
  have h := (valid_parts t accepted).1
  exact (show sameSupport t.input t.output = true ∧ t.output.Nodup from by
    simpa [quotientValid, kind] using h).2

theorem fibers_partition_input (t : Trace) (accepted : valid t = true) :
    t.fibers.flatten.Perm (List.range t.input.length) := by
  have h := (valid_parts t accepted).2
  simp only [fibersValid, Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.1.1.1.2

theorem fibers_have_one_entry_per_output (t : Trace) (accepted : valid t = true) :
    t.fibers.length = t.output.length := by
  have h := (valid_parts t accepted).2
  simp only [fibersValid, Bool.and_eq_true, decide_eq_true_eq] at h
  simpa using h.1.1.1.1

theorem fiber_members_preserve_identity (t : Trace) (accepted : valid t = true)
    (pair : Nat × List Nat) (present : pair ∈ t.output.zip t.fibers)
    (index : Nat) (member : index ∈ pair.2) : t.input[index]? = some pair.1 := by
  have h := (valid_parts t accepted).2
  simp only [fibersValid, Bool.and_eq_true, decide_eq_true_eq] at h
  have fiber := (List.all_eq_true.mp h.1.1.2) pair present
  simp only [Bool.and_eq_true] at fiber
  have values : pair.2.all (fun i => t.input[i]? == some pair.1) = true := by
    exact fiber.2
  simpa using (List.all_eq_true.mp values) index member

theorem nonset_fibers_are_singletons (t : Trace) (accepted : valid t = true)
    (kind : t.kind ≠ .set) (fiber : List Nat) (present : fiber ∈ t.fibers) :
    fiber.length = 1 := by
  have h := (valid_parts t accepted).2
  simp only [fibersValid, Bool.and_eq_true, decide_eq_true_eq] at h
  have singletons : t.fibers.all (fun fiber => fiber.length == 1) = true := by
    simpa [kind] using h.1.2
  simpa using (List.all_eq_true.mp singletons) fiber present

theorem set_preserves_any_denotation (t : Trace)
    (accepted : valid t = true) (kind : t.kind = .set) (denote : Nat → Prop) :
    (∃ x ∈ t.input, denote x) ↔ (∃ x ∈ t.output, denote x) := by
  have support := set_preserves_support t accepted kind
  constructor
  · rintro ⟨x, member, value⟩
    exact ⟨x, (support x).mp member, value⟩
  · rintro ⟨x, member, value⟩
    exact ⟨x, (support x).mpr member, value⟩

theorem set_preserves_all_denotation (t : Trace)
    (accepted : valid t = true) (kind : t.kind = .set) (denote : Nat → Prop) :
    (∀ x ∈ t.input, denote x) ↔ (∀ x ∈ t.output, denote x) := by
  have support := set_preserves_support t accepted kind
  constructor
  · intro h x member
    exact h x ((support x).mpr member)
  · intro h x member
    exact h x ((support x).mp member)

end ACGN.ContainerReplay
