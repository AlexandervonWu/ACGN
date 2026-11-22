import GuardedDomainProjection

namespace NaturalGuardedImport
open GuardedDomainProjection PaidImportedBinding TemporalPhaseLocalBinding

def sourceHash : String := "494780058c00f33497a954fda9179fa90fb947ce47c6812d67bc728dea20064a"
def sourceOrigin : BinderOrigin := ⟨0, 1, 0, 0⟩
def targetOrigin : BinderOrigin := ⟨1, 1, 0, 0⟩
/- Lineages 0/1 name the two predicates within the separately hashed source
   binding. They are not JVM addresses or invented retained occurrence IDs. -/
def source : Endpoint :=
  { origin := sourceOrigin, type := "RELATION[4:File]", quantifier := .some,
    domain := .carrier "File", dependencies := [], multiplicity := 1, disjointness := 0,
    matrix := .implies (.member "Protected") (.historically (.member "Protected")),
    ownerPath := [.unary .always] }
def target : Endpoint :=
  { source with
    origin := targetOrigin, quantifier := .all,
    domain := .subset "File" "Protected", matrix := .historically (.member "Protected") }
def currentPath : List TemporalPhaseRole := [.unary .always]
def historyPath : List TemporalPhaseRole := [.unary .always, .unary .historically]
def unchangedEdits (path : List TemporalPhaseRole) := path.map fun r => (r,r)

theorem strict_old_gate_rejects_forward : sameFrame source.binding target.binding = false := by decide
theorem strict_old_gate_rejects_reverse : sameFrame target.binding source.binding = false := by decide
theorem actual_projected_guard : source.lowered = target.lowered := by decide

theorem forward_paid_current : transportGuarded source source target source.projection target.projection
    [] ⟨source.origin,currentPath⟩ (unchangedEdits currentPath) = some (⟨target.origin,currentPath⟩,1) := by decide
theorem forward_paid_history : transportGuarded source source target source.projection target.projection
    [] ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = some (⟨target.origin,historyPath⟩,1) := by decide
theorem reverse_paid_current : transportGuarded target target source target.projection source.projection
    [] ⟨target.origin,currentPath⟩ (unchangedEdits currentPath) = some (⟨source.origin,currentPath⟩,1) := by decide
theorem reverse_paid_history : transportGuarded target target source target.projection source.projection
    [] ⟨target.origin,historyPath⟩ (unchangedEdits historyPath) = some (⟨source.origin,historyPath⟩,1) := by decide

def sourceReads : List PhaseImport := [⟨source.origin,currentPath⟩,⟨source.origin,historyPath⟩]
def targetReads : List PhaseImport := [⟨target.origin,currentPath⟩,⟨target.origin,historyPath⟩]
theorem forward_two_reads_one_selected_payment : replaySelectedPath source source target
    source.projection target.projection [] sourceReads = some (targetReads,1) := by decide
theorem reverse_two_reads_one_selected_payment : replaySelectedPath target target source
    target.projection source.projection [] targetReads = some (sourceReads,1) := by decide
theorem batch_foreign_read_rejected : replaySelectedPath source source target
    source.projection target.projection [] [⟨source.origin,currentPath⟩,⟨target.origin,historyPath⟩] = none := by decide

/- Every time-indexed File/Protected subset model, not static signatures. -/
def world {V : Type} (file selected : Nat → V → Prop) : World V :=
  fun name _ time value =>
    if name = "File" then file time value
    else if name = "Protected" then file time value ∧ selected time value else False

def actualSource {V : Type} (file selected : Nat → V → Prop) (now : Nat) : Prop :=
  futureAlways (fun owner => ∃ value, file owner value ∧
    (world file selected "Protected" [] owner value →
      pastHistorically (fun past => world file selected "Protected" [] past value) owner)) now

def actualTarget {V : Type} (file selected : Nat → V → Prop) (now : Nat) : Prop :=
  futureAlways (fun owner => ∀ value, world file selected "Protected" [] owner value →
    pastHistorically (fun past => world file selected "Protected" [] past value) owner) now

theorem source_semantics_instantiated {V : Type} (file selected : Nat → V → Prop) (now : Nat) :
    actualSource file selected now ↔ futureAlways
      (fun owner => sourceEval (world file selected) [] owner source.quantifier source.domain source.matrix) now := by
  rfl

theorem target_semantics_instantiated {V : Type} (file selected : Nat → V → Prop) (now : Nat) :
    actualTarget file selected now ↔ futureAlways
      (fun owner => sourceEval (world file selected) [] owner target.quantifier target.domain target.matrix) now := by
  simp [actualTarget, sourceEval, target, source, quantify, domainEval, world,
    Matrix.eval, futureAlways, and_imp]

theorem forward_actual_path {V : Type} (file selected : Nat → V → Prop) (now : Nat) :
    actualTarget file selected now ↔ futureAlways
      (fun owner => editedNative (world file selected) [] owner source target) now := by
  rw [target_semantics_instantiated]
  unfold futureAlways
  apply forall_congr'
  intro owner
  apply imp_congr_right
  intro _
  exact (paid_guarded_path_sound (world file selected) [] owner source target
    source.projection target.projection [] (by decide) (by decide)
    historyPath historyPath (unchangedEdits historyPath) 0 (by decide) (by decide) (by decide)).2.2.symm

theorem reverse_actual_path {V : Type} (file selected : Nat → V → Prop) (now : Nat) :
    actualSource file selected now ↔ futureAlways
      (fun owner => editedNative (world file selected) [] owner target source) now := by
  rw [source_semantics_instantiated]
  unfold futureAlways
  apply forall_congr'
  intro owner
  apply imp_congr_right
  intro _
  exact (paid_guarded_path_sound (world file selected) [] owner target source
    target.projection source.projection [] (by decide) (by decide)
    historyPath historyPath (unchangedEdits historyPath) 0 (by decide) (by decide) (by decide)).2.2.symm

theorem history_keeps_lexical_value {V : Type} (file selected : Nat → V → Prop)
    (before after : Nat → V) (value : V) (owner : Nat) :
    Matrix.eval (world file selected) [] (.historically (.member "Protected")) owner
      (shadowBinder before source.origin.coordinate value source.origin.coordinate) =
    Matrix.eval (world file selected) [] (.historically (.member "Protected")) owner
      (shadowBinder after target.origin.coordinate value target.origin.coordinate) := by
  exact selected_snapshot_read (world file selected) [] before after _ _ value _ owner

theorem forward_complete_selected_path {V : Type} (file selected : Nat → V → Prop) (now : Nat) :
    replaySelectedPath source source target source.projection target.projection [] sourceReads =
      some (targetReads,1) ∧
    (actualTarget file selected now ↔ futureAlways
      (fun owner => editedNative (world file selected) [] owner source target) now) := by
  exact ⟨forward_two_reads_one_selected_payment, forward_actual_path file selected now⟩

theorem reverse_complete_selected_path {V : Type} (file selected : Nat → V → Prop) (now : Nat) :
    replaySelectedPath target target source target.projection source.projection [] targetReads =
      some (sourceReads,1) ∧
    (actualSource file selected now ↔ futureAlways
      (fun owner => editedNative (world file selected) [] owner target source) now) := by
  exact ⟨reverse_two_reads_one_selected_payment, reverse_actual_path file selected now⟩

theorem erased_guard_rejected : transportGuarded source source target source.projection
    {target.projection with body := target.matrix} [] ⟨source.origin,historyPath⟩
    (unchangedEdits historyPath) = none := by decide
theorem changed_guard_rejected : transportGuarded source source target source.projection
    {target.projection with body := .implies (.member "Trash") target.matrix} []
    ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem misplaced_guard_rejected : transportGuarded source source target source.projection
    {target.projection with body := .historically (.implies (.member "Protected") (.member "Protected"))}
    [] ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem unaccounted_domain_rejected :
    let foreign := {target with domain := .subset "File" "Trash"}
    transportGuarded source source foreign source.projection foreign.projection []
      ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem foreign_origin_rejected : transportGuarded source source target source.projection target.projection
    [] ⟨{source.origin with sourceLineage := 7},historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem wrong_owner_rejected : transportGuarded source source target source.projection target.projection
    [] ⟨{source.origin with ownerPhase := 0},historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem wrong_phase_rejected : transportGuarded source source target source.projection target.projection
    [] ⟨source.origin,[.unary .historically]⟩ [(.unary .historically,.unary .historically)] = none := by decide
theorem wrong_payment_rejected : transportGuarded source target target source.projection target.projection
    [] ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem unchanged_head_not_paid : transportGuarded source source source source.projection source.projection
    [] ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem wrong_role_rejected : transportGuarded source source target source.projection target.projection
    [] ⟨source.origin,historyPath⟩ [(.unary .always,.unary .always),(.unary .historically,.binaryLeft .since)] = none := by decide
theorem wrong_type_rejected :
    let foreign := {target with type := "RELATION[5:Other]"}
    transportGuarded source source foreign source.projection foreign.projection []
      ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem wrong_cardinality_rejected :
    let foreign := {target with multiplicity := 2}
    transportGuarded source source foreign source.projection foreign.projection []
      ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide
theorem wrong_disjointness_rejected :
    let foreign := {target with disjointness := 1}
    transportGuarded source source foreign source.projection foreign.projection []
      ⟨source.origin,historyPath⟩ (unchangedEdits historyPath) = none := by decide

def dep0 : Dependency := ⟨⟨2,0,0,0⟩,"RELATION[4:File]"⟩
def dep1 : Dependency := ⟨⟨3,0,0,1⟩,"RELATION[4:File]"⟩
theorem ordered_dependencies_accepted : dependenciesCheck [dep0,dep1] [dep0,dep1]
    [(dep0,dep0),(dep1,dep1)] = true := by decide
theorem reordered_dependencies_rejected : dependenciesCheck [dep0,dep1] [dep1,dep0]
    [(dep0,dep1),(dep1,dep0)] = false := by decide
theorem wrong_dependency_owner_rejected : dependenciesCheck [dep0] [dep1]
    [(dep0,dep0)] = false := by decide
theorem erased_dependencies_rejected : dependenciesCheck [dep0] [] [] = false := by decide
theorem duplicate_dependencies_rejected : dependenciesCheck [dep0,dep0] [dep0,dep0]
    [(dep0,dep0),(dep0,dep0)] = false := by decide

/- Countermodels are derived semantic controls, not additional corpus files. -/
theorem moving_guard_to_history_is_unsound :
    ¬ ((1 = 1 → pastHistorically (fun t => t = 1) 1) ↔
      pastHistorically (fun t => t = 1 → t = 1) 1) := by
  intro h
  have bad := h.mpr (by intro t _ same; exact same) rfl
  have impossible := bad 0 (by decide)
  cases impossible

theorem erasing_guard_is_unsound :
    ¬ ((∀ v : Bool, v = true → v = true) ↔ (∀ v : Bool, v = true)) := by
  intro h
  have impossible := h.mp (fun _ same => same) false
  cases impossible

end NaturalGuardedImport
