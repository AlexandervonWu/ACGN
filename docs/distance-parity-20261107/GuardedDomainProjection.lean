import PaidImportedBinding

/- Domain lowering is an endpoint equivalence. Changing the quantifier is a
   paid edit, not an equivalence. Signature membership is evaluated at the
   declaration time; temporal bodies keep the same lexical value. -/
namespace GuardedDomainProjection
open PaidImportedBinding TemporalPhaseLocalBinding

inductive Quantifier where
  | all | some
  deriving DecidableEq, Repr

def Quantifier.code : Quantifier → Nat | .all => 0 | .some => 1

def quantify {V : Type} : Quantifier → (V → Prop) → (V → Prop) → Prop
  | .all, domain, body => ∀ v, domain v → body v
  | .some, domain, body => ∃ v, domain v ∧ body v

inductive Domain where
  | carrier (name : String)
  | subset (carrierName name : String)
  deriving DecidableEq, Repr

def Domain.carrierName : Domain → String
  | .carrier c => c | .subset c _ => c
def Domain.sourceName : Domain → String
  | .carrier c => c | .subset _ name => name

inductive Matrix where
  | truth
  | member (signature : String)
  | conj (left right : Matrix)
  | implies (left right : Matrix)
  | historically (body : Matrix)
  deriving DecidableEq, Repr

/- An interpretation may depend on the ordered lexical dependency values and
   vary at every instant. No persistence of either signature is assumed. -/
abbrev World (V : Type) := String → List V → Nat → V → Prop

def Matrix.eval {V : Type} (w : World V) (deps : List V) : Matrix → Nat → V → Prop
  | .truth, _, _ => True
  | .member name, time, value => w name deps time value
  | .conj a b, time, value => a.eval w deps time value ∧ b.eval w deps time value
  | .implies a b, time, value => a.eval w deps time value → b.eval w deps time value
  | .historically a, time, value => pastHistorically (fun past => a.eval w deps past value) time

def domainEval {V : Type} (w : World V) (deps : List V) (time : Nat) : Domain → V → Prop
  | .carrier c, value => w c deps time value
  | .subset c name, value => w c deps time value ∧ w name deps time value

def lowerBody : Quantifier → Domain → Matrix → Matrix
  | _, .carrier _, body => body
  | .all, .subset _ name, body => .implies (.member name) body
  | .some, .subset _ name, body => .conj (.member name) body

def sourceEval {V : Type} (w : World V) (deps : List V) (time : Nat)
    (q : Quantifier) (d : Domain) (body : Matrix) : Prop :=
  quantify q (domainEval w deps time d) (body.eval w deps time)

def nativeEval {V : Type} (w : World V) (deps : List V) (time : Nat)
    (q : Quantifier) (carrier : String) (body : Matrix) : Prop :=
  quantify q (w carrier deps time) (body.eval w deps time)

theorem endpoint_lowering {V : Type} (w : World V) (deps : List V) (time : Nat)
    (q : Quantifier) (d : Domain) (body : Matrix) :
    sourceEval w deps time q d body ↔
      nativeEval w deps time q d.carrierName (lowerBody q d body) := by
  cases q <;> cases d <;>
    simp [sourceEval, nativeEval, quantify, domainEval, Domain.carrierName,
      lowerBody, Matrix.eval, and_assoc]

/- A subset declaration's source membership is not identified with its
   carrier. Its parser-declared inclusion supplies exactly this interpretation. -/
theorem declared_subset_denotation {V : Type} (carrier subset body : V → Prop)
    (included : ∀ v, subset v → carrier v) (q : Quantifier) :
    quantify q subset body ↔ quantify q (fun v => carrier v ∧ subset v) body := by
  have domains : subset = (fun v => carrier v ∧ subset v) := by
    funext v
    exact propext ⟨fun h => ⟨included v h, h⟩, fun h => h.2⟩
  rw [← domains]

theorem native_not_in_or_guard (membership body : Prop) :
    (¬ membership ∨ body) ↔ (membership → body) := by
  classical
  by_cases h : membership <;> simp [h]

structure Dependency where
  origin : BinderOrigin
  type : String
  deriving DecidableEq, Repr

structure Endpoint where
  origin : BinderOrigin
  type : String
  quantifier : Quantifier
  domain : Domain
  dependencies : List Dependency
  multiplicity : Nat
  disjointness : Nat
  matrix : Matrix
  ownerPath : List TemporalPhaseRole
  deriving DecidableEq

def Endpoint.binding (a : Endpoint) : Binding :=
  { origin := a.origin, carrier := a.type, domain := a.domain.sourceName,
    dependencies := a.dependencies.map (fun d => d.origin.coordinate),
    quantifier := a.quantifier.code, multiplicity := a.multiplicity,
    disjointness := a.disjointness }

def Endpoint.nativeBinding (a : Endpoint) : Binding :=
  { a.binding with domain := a.domain.carrierName }

def Endpoint.lowered (a : Endpoint) : Matrix := lowerBody a.quantifier a.domain a.matrix

/- Links must be the exact ordered selected dependency owners, with no alias.
   Their values are transported in that order, never reconstructed as []. -/
def dependenciesCheck (a b : List Dependency) (links : List (Dependency × Dependency)) : Bool :=
  decide (a.length = b.length ∧ links = a.zip b ∧
    (a.map (·.origin)).Nodup ∧ (b.map (·.origin)).Nodup ∧
    a.map (fun d => (d.type, d.origin.coordinate, d.origin.ownerPhase)) =
      b.map (fun d => (d.type, d.origin.coordinate, d.origin.ownerPhase)))

structure Environment (V : Type) where
  owners : List Dependency
  values : List V
  arity : owners.length = values.length

def Environment.relabel {V : Type} (env : Environment V) (owners : List Dependency)
    (length : owners.length = env.owners.length) : Environment V :=
  ⟨owners, env.values, length.trans env.arity⟩

theorem ordered_environment_transport {V : Type} (env : Environment V)
    (owners : List Dependency) (length : owners.length = env.owners.length)
    (w : World V) (body : Matrix) (time : Nat) (value : V) :
    (env.relabel owners length).owners = owners ∧
    (env.relabel owners length).values = env.values ∧
    body.eval w (env.relabel owners length).values time value =
      body.eval w env.values time value := by exact ⟨rfl, rfl, rfl⟩

structure Projection where
  domain : Domain
  body : Matrix
  ownerPath : List TemporalPhaseRole
  deriving DecidableEq

def Endpoint.projection (a : Endpoint) : Projection :=
  ⟨a.domain, a.lowered, a.ownerPath⟩

def gate (a b : Endpoint) (pa pb : Projection)
    (links : List (Dependency × Dependency)) : Bool :=
  decide (pa = a.projection ∧ pb = b.projection ∧ pa.body = pb.body ∧
    a.domain.carrierName = b.domain.carrierName ∧ a.ownerPath = b.ownerPath) &&
    dependenciesCheck a.dependencies b.dependencies links &&
    sameFrame a.nativeBinding b.nativeBinding

def transportGuarded (a expected b : Endpoint) (pa pb : Projection)
    (links : List (Dependency × Dependency)) (read : PhaseImport)
    (edits : List (TemporalPhaseRole × TemporalPhaseRole)) : Option (PhaseImport × Nat) := do
  if a != expected || !gate a b pa pb links ||
      read.targetPath.take a.ownerPath.length != a.ownerPath then none
  else
    let (result, cost) ← transport a.nativeBinding expected.nativeBinding b.nativeBinding read edits
    if result.targetPath.take b.ownerPath.length == b.ownerPath then some (result, cost) else none

theorem gate_preserves_actual_guard (a b : Endpoint) (pa pb : Projection)
    (links : List (Dependency × Dependency)) (accepted : gate a b pa pb links = true) :
    pa = a.projection ∧ pb = b.projection ∧ a.lowered = b.lowered ∧
    a.domain.carrierName = b.domain.carrierName ∧ a.ownerPath = b.ownerPath := by
  have h : (pa = a.projection ∧ pb = b.projection ∧ pa.body = pb.body ∧
    a.domain.carrierName = b.domain.carrierName ∧ a.ownerPath = b.ownerPath) := by
    exact of_decide_eq_true (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp accepted).1).1
  exact ⟨h.1, h.2.1, by simpa [h.1, h.2.1, Endpoint.projection] using h.2.2.1,
    h.2.2.2.1, h.2.2.2.2⟩

/- This is the endpoint licensed by the selected paid header, using the
   SOURCE's lowered body. It is not defined to be the target formula. -/
def editedNative {V : Type} (w : World V) (deps : List V) (time : Nat)
    (source target : Endpoint) : Prop :=
  nativeEval w deps time target.quantifier source.domain.carrierName source.lowered

theorem paid_guarded_path_sound {V : Type} (w : World V) (deps : List V) (time : Nat)
    (a b : Endpoint) (pa pb : Projection) (links : List (Dependency × Dependency))
    (accepted : gate a b pa pb links = true)
    (changed : a.quantifier.code ≠ b.quantifier.code)
    (sourcePath targetPath : List TemporalPhaseRole)
    (edits : List (TemporalPhaseRole × TemporalPhaseRole)) (temporalCost : Nat)
    (route : replayRoles sourcePath edits = some (targetPath, temporalCost))
    (sourceOwner : sourcePath.take a.ownerPath.length = a.ownerPath)
    (targetOwner : targetPath.take b.ownerPath.length = b.ownerPath) :
    transportGuarded a a b pa pb links ⟨a.origin, sourcePath⟩ edits =
      some (⟨b.origin, targetPath⟩, 1 + temporalCost) ∧
    (sourceEval w deps time a.quantifier a.domain a.matrix ↔
      nativeEval w deps time a.quantifier a.domain.carrierName a.lowered) ∧
    (editedNative w deps time a b ↔ sourceEval w deps time b.quantifier b.domain b.matrix) := by
  have frame : sameFrame a.nativeBinding b.nativeBinding = true :=
    (Bool.and_eq_true_iff.mp accepted).2
  have keep := gate_preserves_actual_guard a b pa pb links accepted
  refine ⟨?_, endpoint_lowering w deps time a.quantifier a.domain a.matrix, ?_⟩
  · have replay := selected_paid_update_transports_exact_import a.nativeBinding b.nativeBinding
        sourcePath targetPath edits temporalCost route frame changed
    change transport a.nativeBinding a.nativeBinding b.nativeBinding
      ⟨a.origin, sourcePath⟩ edits = some (⟨b.origin, targetPath⟩, 1 + temporalCost) at replay
    simp [transportGuarded, accepted, sourceOwner, replay, targetOwner]
  · unfold editedNative
    rw [keep.2.2.2.1, keep.2.2.1]
    exact (endpoint_lowering w deps time b.quantifier b.domain b.matrix).symm

theorem selected_snapshot_read {V : Type} (w : World V) (deps : List V)
    (sourceEnv targetEnv : Nat → V) (sourceSlot targetSlot : Nat) (value : V)
    (body : Matrix) (time : Nat) :
    body.eval w deps time (shadowBinder sourceEnv sourceSlot value sourceSlot) =
      body.eval w deps time (shadowBinder targetEnv targetSlot value targetSlot) := by
  simp [shadowBinder]

theorem checked_dependency_environment {V : Type} (env : Environment V)
    (a b : Endpoint) (pa pb : Projection) (links : List (Dependency × Dependency))
    (owners : env.owners = a.dependencies) (accepted : gate a b pa pb links = true)
    (w : World V) (time : Nat) :
    ∃ result : Environment V,
      result.owners = b.dependencies ∧ result.values = env.values ∧
      links = a.dependencies.zip b.dependencies ∧
      (editedNative w env.values time a b ↔
        sourceEval w result.values time b.quantifier b.domain b.matrix) := by
  have depCheck := (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp accepted).1).2
  have details := of_decide_eq_true depCheck
  have length : b.dependencies.length = env.owners.length := by
    rw [owners]
    exact details.1.symm
  refine ⟨env.relabel b.dependencies length, rfl, rfl, details.2.1, ?_⟩
  have keep := gate_preserves_actual_guard a b pa pb links accepted
  change nativeEval w env.values time b.quantifier a.domain.carrierName a.lowered ↔ _
  rw [keep.2.2.2.1, keep.2.2.1]
  exact (endpoint_lowering w env.values time b.quantifier b.domain b.matrix).symm

/- Each read checks the SAME selected declaration payment. The path total
   comes from that replay once, not from summing a fresh charge per use. -/
def replayReads (a expected b : Endpoint) (pa pb : Projection)
    (links : List (Dependency × Dependency)) (reads : List PhaseImport) : Option (List PhaseImport) :=
  reads.mapM fun read => do
    let (result, cost) ← transportGuarded a expected b pa pb links read
      (read.targetPath.map fun role => (role, role))
    if cost == 1 then some result else none

def replaySelectedPath (a expected b : Endpoint) (pa pb : Projection)
    (links : List (Dependency × Dependency)) (reads : List PhaseImport) :
    Option (List PhaseImport × Nat) := do
  if a != expected || !gate a b pa pb links then none
  else
    let (output, cost, pairs) ← PaidDeclarationAlignment.replay [atom a.nativeBinding]
      [.pair (atom expected.nativeBinding) (atom b.nativeBinding)]
    if output == [atom b.nativeBinding] && cost == 1 &&
        pairs == [(a.origin.coordinate,b.origin.coordinate)] then
      let imports ← replayReads a expected b pa pb links reads
      some (imports, cost)
    else none

theorem selected_path_charged_once (a expected b : Endpoint) (pa pb : Projection)
    (links : List (Dependency × Dependency)) (reads imports : List PhaseImport) (cost : Nat)
    (accepted : replaySelectedPath a expected b pa pb links reads = some (imports,cost)) : cost = 1 := by
  unfold replaySelectedPath at accepted
  split at accepted
  · contradiction
  · cases h : PaidDeclarationAlignment.replay [atom a.nativeBinding]
      [.pair (atom expected.nativeBinding) (atom b.nativeBinding)] with
    | none => simp [h] at accepted
    | some result =>
      rcases result with ⟨output, charged, pairs⟩
      simp only [h] at accepted
      dsimp only [Bind.bind, Option.bind] at accepted
      split at accepted
      · next checks =>
          have charge : charged = 1 := by
            have parts := (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp checks).1).2
            exact of_decide_eq_true parts
          cases r : replayReads a expected b pa pb links reads <;> simp [r, charge] at accepted
          exact accepted.2.symm
      · contradiction

theorem altered_projection_rejected (a b : Endpoint) (pa pb : Projection)
    (links : List (Dependency × Dependency)) (read : PhaseImport)
    (edits : List (TemporalPhaseRole × TemporalPhaseRole)) (wrong : pa ≠ a.projection) :
    transportGuarded a a b pa pb links read edits = none := by
  simp [transportGuarded, gate, wrong]

end GuardedDomainProjection
