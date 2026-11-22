import SelectedDeclarationPathTransport

/- Native trace choices in the existing metric representation. These results
   neither add a scalar candidate nor exchange source-language quantifiers. -/
namespace NativeDeclarationTraceCoherence
open SelectedDeclarationCompletion SelectedDeclarationPathTransport

def linked (mapping : Mapping) : Step → Prop
  | .pair a b => mapping a.vectorIndex = some b.vectorIndex
  | .delete a => mapping a.vectorIndex = none
  | .insert b => ∀ i, mapping i ≠ some b.vectorIndex

theorem selected_tie_preserves_component (old chosen : List Step) (source target : List Binding)
    (n : Nat) (mapping : Mapping)
    (oldSource : sources old = source) (newSource : sources chosen = source)
    (oldReplay : replay source old = some (target,n))
    (newReplay : replay source chosen = some (target,n))
    (allLinked : ∀ step ∈ chosen, linked mapping step) :
    cost old = cost chosen ∧ targets chosen = target ∧
      ∀ a b, Step.pair a b ∈ chosen → mapping a.vectorIndex = some b.vectorIndex := by
  obtain ⟨payment,endpoint⟩ := tied_linked_path_retains_payment old chosen source target n
    oldSource newSource oldReplay newReplay
  exact ⟨payment,endpoint,fun a b member => allLinked (.pair a b) member⟩

def deletions (bindings : List Binding) : List Step := bindings.map Step.delete
def insertions (bindings : List Binding) : List Step := bindings.map Step.insert

theorem delete_all (bindings : List Binding) :
    replay bindings (deletions bindings) = some ([],bindings.length) := by
  induction bindings with
  | nil => rfl
  | cons head tail ih =>
    simp only [deletions] at ih
    simp [deletions,replay,ih]

theorem insert_all (bindings : List Binding) :
    replay [] (insertions bindings) = some (bindings,bindings.length) := by
  induction bindings with
  | nil => rfl
  | cons head tail ih =>
    simp only [insertions] at ih
    simp [insertions,replay,ih]

-- The sorted list is only a metric-coordinate presentation of the same issued
-- records. Every owner, phase, dependency, type and source occurrence survives.
theorem unmatched_phase_presentation (issued ordered : List Binding)
    (permutation : ordered.Perm issued) :
    replay ordered (deletions ordered) = some ([],issued.length) ∧
    replay [] (insertions ordered) = some (ordered,issued.length) ∧
    ∀ binding, binding ∈ ordered ↔ binding ∈ issued := by
  refine ⟨?_,?_,fun _ => permutation.mem_iff⟩
  · simpa [permutation.length_eq] using delete_all ordered
  · simpa [permutation.length_eq] using insert_all ordered

theorem presented_slot_still_issued (issued ordered : List Binding)
    (permutation : ordered.Perm issued)
    (associatedAll : ∀ binding ∈ issued, associated issued binding.vectorIndex binding = true)
    (binding : Binding) (member : binding ∈ ordered) :
    issued[binding.vectorIndex]? = some binding :=
  (associated_exact issued binding.vectorIndex binding
    (associatedAll binding (permutation.mem_iff.mp member))).1

def tieHash := "f90b8807fd06ee7f51fceb7674f72b76d54669344b03827022b8f695b6717c47"
def component : Origin := ⟨tieHash,"inv4","root/predicate[0]/decl[0]@pos","",0,
  "MATRIX",[],[],"AlloyCarrier(Component)","19:alloy-binder-domain[1:9:Component]{0:}","ALL","ONE",0⟩
def sourceSlot : Binding := ⟨component,0,0,0⟩
def targetSlot : Binding := ⟨{component with predicate := "inv4c"},0,0,0⟩
def addedSlot : Binding := ⟨{component with
  predicate := "inv4c"
  occurrence := "root/predicate[0]/decl[1]@pos"},1,1,1⟩
def selectedMap : Mapping := fun i => if i = 0 then some 0 else none
def oldTie := [Step.insert targetSlot,.pair sourceSlot addedSlot]
def linkedTie := [Step.pair sourceSlot targetSlot,.insert addedSlot]
def reverseTie := [Step.pair targetSlot sourceSlot,.delete addedSlot]

theorem old_tie_executes_but_not_linked :
    replay [sourceSlot] oldTie = some ([targetSlot,addedSlot],1) ∧
    ¬ linked selectedMap (.pair sourceSlot addedSlot) := by
  simp only [linked]; decide

theorem chosen_tie_executes :
    replay [sourceSlot] linkedTie = some ([targetSlot,addedSlot],1) ∧
    replay [targetSlot,addedSlot] reverseTie = some ([sourceSlot],1) := by decide

theorem chosen_tie_linked : ∀ step ∈ linkedTie, linked selectedMap step := by
  intro step member
  simp only [linkedTie,List.mem_cons,List.not_mem_nil,or_false] at member
  rcases member with rfl | rfl
  · rfl
  · intro i; by_cases h : i = 0 <;> simp [selectedMap,h,addedSlot]

theorem chosen_tie_typed_owner :
    DeclarationKeepTransport.checkedKeep [sourceSlot] [targetSlot,addedSlot] sourceSlot targetSlot = true ∧
    DeclarationKeepTransport.checkedKeep [targetSlot,addedSlot] [sourceSlot] targetSlot sourceSlot = true := by decide

theorem changed_owner_phase_rejected :
    DeclarationKeepTransport.checkedKeep [sourceSlot] [{targetSlot with origin.phase := 1},addedSlot]
      sourceSlot {targetSlot with origin.phase := 1} = false := by decide

def phaseHash := "9e639900097954e2cc17b2b778f4febed014e103c307743d689f6d4c7f502a55"
def phaseUser : Origin := ⟨phaseHash,"inv4","root/temporalroot[0]/decl[0]@pos","",1,
  "MATRIX",[],[],"AlloyCarrier(User)","19:alloy-binder-domain[1:4:User]{0:}","ALL","ONE",0⟩
def phaseWork : Origin := {phaseUser with
  exactType := "AlloyCarrier(Work)"
  domain := "19:alloy-binder-domain[1:4:Work]{0:}"
  occurrence := "root/temporalroot[0]/body[1]/decl[0]@pos"
  disjointness := 1}
def u : Binding := ⟨phaseUser,0,0,0⟩
def w1 : Binding := ⟨phaseWork,1,2,1⟩
def w2 : Binding := ⟨phaseWork,2,3,2⟩
def w0 : Binding := ⟨{phaseWork with
  disjointness := 0
  occurrence := "root/temporalroot[0]/body[1]/body[1]/decl[0]@pos"},3,1,3⟩
def issued := [u,w1,w2,w0]
def ordered := [u,w0,w1,w2]

theorem actual_order_is_permutation : ordered.Perm issued := by
  exact List.Perm.cons u ((List.Perm.swap w1 w0 [w2]).trans
    (List.Perm.cons w1 (List.Perm.swap w2 w0 [])))

theorem old_presentation_differs : issued ≠ ordered := by decide
theorem actual_phase_associations :
    ∀ binding ∈ issued, associated issued binding.vectorIndex binding = true := by
  intro binding member
  simp only [issued,List.mem_cons,List.not_mem_nil,or_false] at member
  rcases member with rfl | rfl | rfl | rfl <;> decide

theorem actual_phase_replays :
    replay ordered (deletions ordered) = some ([],4) ∧
    replay [] (insertions ordered) = some (ordered,4) := by decide

theorem omitted_slot_not_permutation : ¬ [u,w1,w2].Perm issued := by
  intro h; have n := h.length_eq; simp [issued] at n

theorem substituted_phase_not_permutation :
    ¬ [u,w0,w1,{w2 with origin.phase := 0}].Perm issued := by
  intro h
  have member := h.mem_iff.mp (List.mem_cons_of_mem u (List.mem_cons_of_mem w0
    (List.mem_cons_of_mem w1 (List.mem_singleton.mpr rfl))))
  simp [issued,u,w0,w1,w2,phaseWork,phaseUser] at member

end NativeDeclarationTraceCoherence
