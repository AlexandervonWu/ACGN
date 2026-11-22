import EndpointCanonicalContracts
import TemporalPhaseLocalBinding

/- A phase import exposes an existing owner slot. It neither declares a new
   slot nor authorizes exchanging that slot with a same-typed local binder. -/
namespace PhaseScopeBindings
open EndpointCanonicalContracts

structure ScopeKey where
  phase : Nat
  context : Nat
  deriving DecidableEq

structure Payload where
  exactType : Nat
  domain : Nat
  dependencies : List Nat
  quantifier : Nat
  cardinality : Nat
  disjointness : Nat
  orderedRole : Nat
  deriving DecidableEq

structure Binding where
  owner : ScopeKey
  slot : Nat
  lineage : Nat
  payload : Payload
  deriving DecidableEq

structure Import where
  source : Binding
  targetPhase : Nat
  deriving DecidableEq

def acceptsImport (owner : Binding) (phase : Nat) (imported : Import) : Bool :=
  decide (imported.source = owner ∧ imported.targetPhase = phase)

def oldLookup (declared : List Binding) (binding : Binding) : Bool :=
  decide (binding ∈ declared)

def visible (declared : List Binding) (imports : List Import) (phase : Nat)
    (binding : Binding) : Bool :=
  oldLookup declared binding || imports.any (acceptsImport binding phase)

theorem exact_import_visible (declared : List Binding) (binding : Binding) (phase : Nat) :
    visible declared [⟨binding, phase⟩] phase binding = true := by
  simp [visible, acceptsImport]

theorem old_lookup_retained (declared : List Binding) (imports : List Import)
    (phase : Nat) (binding : Binding) (h : oldLookup declared binding = true) :
    visible declared imports phase binding = true := by
  simp [visible, h]

theorem accepted_import_has_exact_owner (owner : Binding) (phase : Nat) (i : Import)
    (h : acceptsImport owner phase i = true) : i.source = owner ∧ i.targetPhase = phase := by
  simpa [acceptsImport] using h

def read (environment : Binding → V) (imported : Import) : V := environment imported.source

theorem imported_read_is_owner_read (environment : Binding → V) (owner : Binding)
    (phase : Nat) (i : Import) (h : acceptsImport owner phase i = true) :
    read environment i = environment owner := by
  simp [read, (accepted_import_has_exact_owner owner phase i h).1]

def sameOrbit (a b : Binding) : Bool :=
  decide (a.owner = b.owner ∧ a.payload = b.payload)

theorem orbit_preserves_scope_and_payload (a b : Binding) (h : sameOrbit a b = true) :
    a.owner = b.owner ∧ a.payload = b.payload := by
  simpa [sameOrbit] using h

structure Use where
  origin : Ref
  phase : Nat

def renameUse (owner : Nat) (p : Nat → Nat) (use : Use) : Use :=
  { use with origin := renameRef owner p use.origin }

def readUse (env : Ref → V) (use : Use) : V := env use.origin

theorem import_transport_commutes (owner : Nat) (p : Permutation)
    (env : Ref → V) (use : Use) :
    readUse (transport owner p.backward env) (renameUse owner p.forward use) =
      readUse env use := by
  exact congrArg env (rename_inverse owner p use.origin)

theorem transport_keeps_use_phase (owner : Nat) (p : Nat → Nat) (use : Use) :
    (renameUse owner p use).phase = use.phase := rfl

theorem local_and_all_imported_uses_share_one_action (owner : Nat) (p : Permutation)
    (env : Ref → V) (uses : List Use) :
    (uses.map (renameUse owner p.forward)).map (readUse (transport owner p.backward env)) =
      uses.map (readUse env) := by
  induction uses with
  | nil => rfl
  | cons use rest ih => simp [import_transport_commutes, ih]

theorem expression_transport (owner : Nat) (p : Permutation) (env : Ref → V) (body : Expr V) :
    eval (transport owner p.backward env) (rename owner p.forward body) = eval env body :=
  eval_rename owner p env body

-- Source shape: retained Train binder in phase[0], read in a descendant ALWAYS.
-- Exact source hashes and Java occurrence/owner checks are bound by the harness.
def train : Payload := ⟨1, 1, [], 0, 1, 0, 0⟩
def ownerSlot : Binding := ⟨⟨0, 7⟩, 0, 41, train⟩
def secondSlot : Binding := ⟨⟨0, 7⟩, 1, 42, train⟩
def importedSlot : Import := ⟨ownerSlot, 1⟩

theorem source_old_gate_rejects : oldLookup [] ownerSlot = false := by decide
theorem source_import_path_accepts : visible [] [importedSlot] 1 ownerSlot = true := by decide
theorem source_import_read_sound (env : Binding → V) : read env importedSlot = env ownerSlot := rfl
theorem same_typed_owner_slots_share_orbit : sameOrbit ownerSlot secondSlot = true := by decide
theorem same_type_other_phase_not_same_orbit :
    sameOrbit ownerSlot {secondSlot with owner := ⟨1, 7⟩} = false := by decide
theorem same_type_shadowed_owner_not_same_orbit :
    sameOrbit ownerSlot {secondSlot with owner := ⟨0, 8⟩} = false := by decide
theorem wrong_type_not_same_orbit :
    sameOrbit ownerSlot {secondSlot with payload := {train with exactType := 2}} = false := by decide
theorem wrong_domain_not_same_orbit :
    sameOrbit ownerSlot {secondSlot with payload := {train with domain := 2}} = false := by decide
theorem wrong_dependencies_not_same_orbit :
    sameOrbit ownerSlot {secondSlot with payload := {train with dependencies := [1]}} = false := by decide
theorem wrong_owner_import_rejected :
    acceptsImport {ownerSlot with owner := ⟨0, 8⟩} 1 importedSlot = false := by decide
theorem wrong_target_import_rejected : acceptsImport ownerSlot 2 importedSlot = false := by decide
theorem wrong_lineage_import_rejected :
    acceptsImport {ownerSlot with lineage := 42} 1 importedSlot = false := by decide

theorem two_slot_transport_at_owner_and_two_heirs (env : Ref → V) :
    ([Use.mk ⟨0, 0⟩ 0, Use.mk ⟨0, 1⟩ 1, Use.mk ⟨0, 0⟩ 2].map (renameUse 0 swap01)).map
      (readUse (transport 0 swap01 env)) =
        [env ⟨0, 0⟩, env ⟨0, 1⟩, env ⟨0, 0⟩] := by
  simpa [readUse] using local_and_all_imported_uses_share_one_action 0
    (Permutation.mk swap01 swap01 swap_twice swap_twice) env
    [Use.mk ⟨0, 0⟩ 0, Use.mk ⟨0, 1⟩ 1, Use.mk ⟨0, 0⟩ 2]

theorem temporal_owner_not_relocated :
    TemporalPhaseLocalBinding.admits TemporalPhaseLocalBinding.sourceBinder
      TemporalPhaseLocalBinding.alwaysImport = true := by decide

#print axioms imported_read_is_owner_read
#print axioms local_and_all_imported_uses_share_one_action
#print axioms expression_transport
#print axioms source_old_gate_rejects
#print axioms source_import_path_accepts
#print axioms source_import_read_sound
#print axioms same_typed_owner_slots_share_orbit
#print axioms two_slot_transport_at_owner_and_two_heirs
end PhaseScopeBindings
