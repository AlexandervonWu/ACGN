import DeclarationKeepTransport

namespace SelectedDeclarationPathTransport
open SelectedDeclarationCompletion DeclarationKeepTransport

abbrev Link := Binding × Binding

inductive Step where
  | pair (source target : Binding)
  | delete (source : Binding)
  | insert (target : Binding)

def sources : List Step → List Binding
  | [] => []
  | .pair a _ :: rest | .delete a :: rest => a :: sources rest
  | .insert _ :: rest => sources rest

def targets : List Step → List Binding
  | [] => []
  | .pair _ b :: rest | .insert b :: rest => b :: targets rest
  | .delete _ :: rest => targets rest

def links : List Step → List Link
  | [] => []
  | .pair a b :: rest => (a,b) :: links rest
  | _ :: rest => links rest

def sameTuple (a b : Binding) : Bool :=
  a.origin.quantifier == b.origin.quantifier && a.origin.exactType == b.origin.exactType &&
  a.origin.cardinality == b.origin.cardinality && a.origin.disjointness == b.origin.disjointness

def stepCost : Step → Nat
  | .pair a b => if sameTuple a b then 0 else 1
  | _ => 1

def cost (path : List Step) : Nat := (path.map stepCost).sum
def paid (path : List Step) : List Link := (links path).filter (fun p => !sameTuple p.1 p.2)
def carried (path : List Step) : List Link :=
  (links path).filter (fun p => !sameTuple p.1 p.2 || p.1.origin.role == "PARAMETER")

def replay : List Binding → List Step → Option (List Binding × Nat)
  | [], [] => some ([],0)
  | _ :: _, [] => none
  | input, .insert b :: rest => do
      let (output,n) ← replay input rest
      pure (b :: output,n+1)
  | a :: input, .delete expected :: rest =>
      if a = expected then do
        let (output,n) ← replay input rest
        pure (output,n+1)
      else none
  | a :: input, .pair expected b :: rest =>
      if a = expected then do
        let (output,n) ← replay input rest
        pure (b :: output,n+stepCost (.pair a b))
      else none
  | [], _ :: _ => none

theorem extracted_path_replays (path : List Step) :
    replay (sources path) path = some (targets path,cost path) := by
  induction path with
  | nil => rfl
  | cons step rest ih => cases step <;> simp [sources,targets,replay,cost,stepCost] at ih ⊢ <;>
      simp_all [Nat.add_comm]

theorem selected_cost_retained (path : List Step) (source target : List Binding) (n : Nat)
    (sourceExact : sources path = source) (selected : replay source path = some (target,n)) :
    targets path = target ∧ cost path = n := by
  rw [← sourceExact,extracted_path_replays] at selected
  exact Prod.mk.inj (Option.some.inj selected)

-- Tie selection may choose the path whose extracted links equal the selected
-- matrix map; both paths still execute and pay the same declaration component.
theorem tied_linked_path_retains_payment (old chosen : List Step) (source target : List Binding) (n : Nat)
    (oldSource : sources old = source) (newSource : sources chosen = source)
    (oldReplay : replay source old = some (target,n))
    (newReplay : replay source chosen = some (target,n)) :
    cost old = cost chosen ∧ targets chosen = target := by
  have a := selected_cost_retained old source target n oldSource oldReplay
  have b := selected_cost_retained chosen source target n newSource newReplay
  exact ⟨a.2.trans b.2.symm,b.1⟩

theorem linked_sources_sublist (path : List Step) :
    List.Sublist ((links path).map (fun p => p.1.vectorIndex)) ((sources path).map Binding.vectorIndex) := by
  induction path with
  | nil => exact List.Sublist.refl _
  | cons step rest ih =>
    cases step with
    | pair a b => exact List.Sublist.cons_cons _ ih
    | delete a => exact List.Sublist.cons _ ih
    | insert b => exact ih

theorem linked_targets_sublist (path : List Step) :
    List.Sublist ((links path).map (fun p => p.2.vectorIndex)) ((targets path).map Binding.vectorIndex) := by
  induction path with
  | nil => exact List.Sublist.refl _
  | cons step rest ih =>
    cases step with
    | pair a b => exact List.Sublist.cons_cons _ ih
    | delete a => exact ih
    | insert b => exact List.Sublist.cons _ ih

theorem key_unique {A : Type} (key : A → Nat) (xs : List A)
    (unique : (xs.map key).Nodup) (a b : A)
    (ha : a ∈ xs) (hb : b ∈ xs) (equal : key a = key b) : a = b := by
  induction xs generalizing a b with
  | nil => simp at ha
  | cons head tail ih =>
    have h := List.nodup_cons.mp unique
    rcases List.mem_cons.mp ha with aHead | aTail
    · rcases List.mem_cons.mp hb with bHead | bTail
      · exact aHead.trans bHead.symm
      · exact False.elim (h.1 (List.mem_map.mpr ⟨b,bTail,equal.symm.trans (congrArg key aHead)⟩))
    · rcases List.mem_cons.mp hb with bHead | bTail
      · exact False.elim (h.1 (List.mem_map.mpr ⟨a,aTail,equal.trans (congrArg key bHead)⟩))
      · exact ih h.2 a b aTail bTail equal

theorem extracted_links_partial_injection (path : List Step)
    (sourceUnique : ((sources path).map Binding.vectorIndex).Nodup)
    (targetUnique : ((targets path).map Binding.vectorIndex).Nodup)
    (a b : Link) (ha : a ∈ links path) (hb : b ∈ links path) :
    (a.1.vectorIndex = b.1.vectorIndex → a = b) ∧
    (a.2.vectorIndex = b.2.vectorIndex → a = b) :=
  ⟨fun equal => key_unique _ _ ((linked_sources_sublist path).nodup sourceUnique) a b ha hb equal,
   fun equal => key_unique _ _ ((linked_targets_sublist path).nodup targetUnique) a b ha hb equal⟩

theorem admitted_orders_preserve_uniqueness (issued ordered : List Binding)
    (permutation : ordered.Perm issued) (unique : (issued.map Binding.vectorIndex).Nodup) :
    (ordered.map Binding.vectorIndex).Nodup :=
  (permutation.map Binding.vectorIndex).nodup_iff.mpr unique

def lookup (key : Link → Nat) (index : Nat) : List Link → Option Link
  | [] => none
  | head :: tail => if key head = index then some head else lookup key index tail

theorem lookup_member (key : Link → Nat) (xs : List Link) (a : Link)
    (unique : (xs.map key).Nodup) (member : a ∈ xs) : lookup key (key a) xs = some a := by
  induction xs with
  | nil => simp at member
  | cons head tail ih =>
    have h := List.nodup_cons.mp unique
    by_cases equal : key head = key a
    · have same := key_unique key (head :: tail) unique head a (by simp) member equal
      simp [lookup,same]
    · rcases List.mem_cons.mp member with same | member
      · subst a; exact False.elim (equal rfl)
      · simp [lookup,equal,ih h.2 member]

theorem selected_roundtrip (path : List Step)
    (sourceUnique : ((sources path).map Binding.vectorIndex).Nodup)
    (targetUnique : ((targets path).map Binding.vectorIndex).Nodup)
    (a b : Binding) (member : (a,b) ∈ links path) :
    lookup (fun p => p.1.vectorIndex) a.vectorIndex (links path) = some (a,b) ∧
    lookup (fun p => p.2.vectorIndex) b.vectorIndex (links path) = some (a,b) :=
  ⟨lookup_member _ _ _ ((linked_sources_sublist path).nodup sourceUnique) member,
   lookup_member _ _ _ ((linked_targets_sublist path).nodup targetUnique) member⟩

-- The source/target binding vectors and the actual Java path-authority branch
-- participate in admission. Literal paths may differ only with both producer
-- prenex certificates. A paid update is not licensed as a typed zero keep.
def pathAuthority (sourcePrenex targetPrenex : Binding → Bool) (a b : Binding) : Bool :=
  (sourcePrenex a && targetPrenex b) || a.origin.occurrence == b.origin.occurrence

def admissible (source target : List Binding) (sourcePrenex targetPrenex : Binding → Bool)
    (path : List Step) : Bool :=
  (links path).all fun p => associated source p.1.vectorIndex p.1 && associated target p.2.vectorIndex p.2 &&
    (if sameTuple p.1 p.2 then checkedKeep source target p.1 p.2 && pathAuthority sourcePrenex targetPrenex p.1 p.2 else true)

theorem admitted_zero_keep (source target : List Binding) (sp tp : Binding → Bool)
    (path : List Step) (a b : Binding) (accepted : admissible source target sp tp path = true)
    (member : (a,b) ∈ links path) (zero : sameTuple a b = true) :
    checkedKeep source target a b = true ∧ pathAuthority sp tp a b = true := by
  have h := List.all_eq_true.mp accepted (a,b) member
  simp only [zero, ite_true, Bool.and_eq_true] at h
  exact h.2

def targetRead {Value : String → Type} (environment : (a : Binding) → Value a.origin.exactType)
    (path : List Step) (target : Binding) : Option (Value target.origin.exactType) :=
  match lookup (fun p => p.2.vectorIndex) target.vectorIndex (links path) with
  | none => none
  | some (source,actualTarget) =>
    if actualTarget = target then
      if equal : source.origin.exactType = target.origin.exactType
        then some (cast (congrArg Value equal) (environment source)) else none
    else none

theorem selected_target_typed_read {Value : String → Type}
    (environment : (a : Binding) → Value a.origin.exactType)
    (source target : List Binding) (sp tp : Binding → Bool) (path : List Step) (a b : Binding)
    (accepted : admissible source target sp tp path = true)
    (unique : ((targets path).map Binding.vectorIndex).Nodup)
    (member : (a,b) ∈ links path) (zero : sameTuple a b = true) :
    target[b.vectorIndex]? = some b ∧ ∃ value : Value b.origin.exactType,
      targetRead environment path b = some value ∧ HEq value (environment a) := by
  have keep := (admitted_zero_keep source target sp tp path a b accepted member zero).1
  have actual := (keep_has_original_endpoints source target a b keep).2
  have typed := (keep_has_same_type_and_owner source target a b keep).1
  have found := lookup_member (fun p => p.2.vectorIndex) (links path) (a,b)
    ((linked_targets_sublist path).nodup unique) member
  refine ⟨actual,cast (congrArg Value typed) (environment a),?_,cast_heq _ _⟩
  simp [targetRead,found,typed]

theorem extracted_paid_exact (path : List Step) (a b : Binding) :
    (a,b) ∈ paid path ↔ (a,b) ∈ links path ∧ sameTuple a b = false := by
  simp [paid]

theorem zero_not_charged (path : List Step) (a b : Binding) (zero : sameTuple a b = true) :
    (a,b) ∉ paid path := by simp [paid,zero]

theorem source_path_needs_authority (a b : Binding) (different : a.origin.occurrence ≠ b.origin.occurrence) :
    pathAuthority (fun _ => false) (fun _ => true) a b = false := by
  simp [pathAuthority,different]

def witness : List Step := [.pair a0 b0,.delete a1,.pair a2 b1]

theorem witness_admitted : admissible [a0,a1,a2] [b0,b1] (fun _ => true) (fun _ => true) witness = true := by decide
theorem witness_links : links witness = [(a0,b0),(a2,b1)] := rfl
theorem witness_paid : paid witness = [] := by decide
theorem witness_source_unique : ((sources witness).map Binding.vectorIndex).Nodup := by decide
theorem witness_target_unique : ((targets witness).map Binding.vectorIndex).Nodup := by decide
theorem witness_replay : replay [a0,a1,a2] witness = some ([b0,b1],1) := by decide

theorem witness_target_read {Value : String → Type}
    (environment : (a : Binding) → Value a.origin.exactType) :
    ∃ value : Value b1.origin.exactType,
      targetRead environment witness b1 = some value ∧ HEq value (environment a2) := by
  exact (selected_target_typed_read environment [a0,a1,a2] [b0,b1] (fun _ => true) (fun _ => true)
    witness a2 b1 witness_admitted witness_target_unique (by simp [witness_links]) (by decide)).2

theorem changed_phase_declined :
    admissible [a0,a1,a2] [b0,{b1 with origin.phase := 1}] (fun _ => true) (fun _ => true)
      [.pair a0 b0,.delete a1,.pair a2 {b1 with origin.phase := 1}] = false := by decide

theorem duplicate_target_not_unique :
    ¬ ((targets [.pair a0 b0,.pair a2 b0]).map Binding.vectorIndex).Nodup := by decide

end SelectedDeclarationPathTransport
