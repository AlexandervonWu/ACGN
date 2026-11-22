import TypedSlottedEGraphsPaper.SyntaxSupport

/- CALL duplicate registration may compare a domain occurrence with its body
   clone. This contract uses the existing intrinsically typed port action.
   It changes neither an invocation's class/interface nor its ordered arguments.
   Java extraction and source-owner association are separate checked bindings. -/
namespace CallContextWeakening
open TypedSlottedEGraphsPaper

structure Metadata where
  occurrence : Nat
  sourceName : String
  callee : String
  kind : String
  arity : Nat
  authority : String
  operatorKey : String
  deriving DecidableEq, Repr

abbrev Signature := ConcreteSyntaxSignature String Unit Nat Unit

abbrev Argument (signature : Signature) (context : TypedSlotContext String) :=
  (output : String) × ScopedPortAtom signature context [] output

structure Payload (signature : Signature) (context : TypedSlotContext String) where
  metadata : Metadata
  arguments : List (Argument signature context)

def actArgument {signature : Signature} {source target : TypedSlotContext String}
    (embedding : TypedSlotEmbedding source target) (argument : Argument signature source) :
    Argument signature target :=
  ⟨argument.1, ScopedPortAtom.act embedding argument.2⟩

def act {signature : Signature} {source target : TypedSlotContext String}
    (embedding : TypedSlotEmbedding source target) (payload : Payload signature source) :
    Payload signature target :=
  ⟨payload.metadata, payload.arguments.map (actArgument embedding)⟩

def evalAtom {signature : Signature} {context : TypedSlotContext String}
    (Value : String → Type)
    (classes : (id : Nat) →
      ((slot : (signature.classInterface id).Slot) →
        Value ((signature.classInterface id).typeOf slot)) → Value (signature.classOutput id))
    (environment : (slot : context.Slot) → Value (context.typeOf slot)) :
    {output : String} → ScopedPortAtom signature context [] output → Value output
  | _, .free slot typed => typed ▸ environment slot
  | _, .boundVar index _ => nomatch index
  | _, .invoke id embedding =>
      classes id (fun slot => embedding.preservesType slot ▸ environment (embedding.toFun slot))

def restrictEnv {source target : TypedSlotContext String}
    (embedding : TypedSlotEmbedding source target) (Value : String → Type)
    (environment : (slot : target.Slot) → Value (target.typeOf slot)) :
    (slot : source.Slot) → Value (source.typeOf slot) :=
  fun slot => embedding.preservesType slot ▸ environment (embedding.toFun slot)

theorem typed_cast_trans (Value : String → Type) {a b c : String}
    (first : a = b) (second : b = c) (value : Value a) :
    (first.trans second) ▸ value = second ▸ first ▸ value := by
  cases first
  cases second
  rfl

theorem atom_action_evaluates {signature : Signature} {source target : TypedSlotContext String}
    (embedding : TypedSlotEmbedding source target) (Value : String → Type)
    (classes : (id : Nat) →
      ((slot : (signature.classInterface id).Slot) →
        Value ((signature.classInterface id).typeOf slot)) → Value (signature.classOutput id))
    (environment : (slot : target.Slot) → Value (target.typeOf slot))
    {output : String} (argument : ScopedPortAtom signature source [] output) :
    evalAtom Value classes environment (ScopedPortAtom.act embedding argument) =
      evalAtom Value classes (restrictEnv embedding Value environment) argument := by
  cases argument with
  | free slot typed => cases typed; rfl
  | boundVar index typed => exact Fin.elim0 index
  | invoke id inner =>
      simp only [evalAtom, ScopedPortAtom.act, TypedSlotEmbedding.comp, restrictEnv]
      congr 1
      funext slot
      exact typed_cast_trans Value (embedding.preservesType (inner.toFun slot))
        (inner.preservesType slot) _

def evalArguments {signature : Signature} {context : TypedSlotContext String}
    (Value : String → Type)
    (classes : (id : Nat) →
      ((slot : (signature.classInterface id).Slot) →
        Value ((signature.classInterface id).typeOf slot)) → Value (signature.classOutput id))
    (environment : (slot : context.Slot) → Value (context.typeOf slot))
    (arguments : List (Argument signature context)) : List ((ty : String) × Value ty) :=
  arguments.map (fun argument => ⟨argument.1, evalAtom Value classes environment argument.2⟩)

theorem arguments_action_evaluates {signature : Signature} {source target : TypedSlotContext String}
    (embedding : TypedSlotEmbedding source target) (Value : String → Type)
    (classes : (id : Nat) →
      ((slot : (signature.classInterface id).Slot) →
        Value ((signature.classInterface id).typeOf slot)) → Value (signature.classOutput id))
    (environment : (slot : target.Slot) → Value (target.typeOf slot))
    (arguments : List (Argument signature source)) :
    evalArguments Value classes environment (arguments.map (actArgument embedding)) =
      evalArguments Value classes (restrictEnv embedding Value environment) arguments := by
  induction arguments with
  | nil => rfl
  | cons head tail ih =>
      simp only [List.map_cons, evalArguments, actArgument, atom_action_evaluates] at *
      exact congrArg (List.cons _) ih

/- Both inverse-inclusion equalities are retained checks, not conclusions
   assumed about an arbitrary normalization. Natural instances below compute
   them from the captured typed invocation maps. The environments must agree
   on every used slot, not merely on a type or a display name. -/
theorem duplicate_payload_sound {signature : Signature}
    {support leftContext rightContext : TypedSlotContext String}
    (leftInclusion : TypedSlotEmbedding support leftContext)
    (rightInclusion : TypedSlotEmbedding support rightContext)
    (exactPayload : Payload signature support)
    (left : Payload signature leftContext) (right : Payload signature rightContext)
    (leftRoundtrip : act leftInclusion exactPayload = left)
    (rightRoundtrip : act rightInclusion exactPayload = right)
    (Value : String → Type)
    (classes : (id : Nat) →
      ((slot : (signature.classInterface id).Slot) →
        Value ((signature.classInterface id).typeOf slot)) → Value (signature.classOutput id))
    (leftEnv : (slot : leftContext.Slot) → Value (leftContext.typeOf slot))
    (rightEnv : (slot : rightContext.Slot) → Value (rightContext.typeOf slot))
    (usedOwnerAgreement : restrictEnv leftInclusion Value leftEnv =
      restrictEnv rightInclusion Value rightEnv)
    {Result : Type} (invoke : Metadata → List ((ty : String) × Value ty) → Result) :
    invoke left.metadata (evalArguments Value classes leftEnv left.arguments) =
      invoke right.metadata (evalArguments Value classes rightEnv right.arguments) := by
  rw [← leftRoundtrip, ← rightRoundtrip]
  simp only [act, arguments_action_evaluates, usedOwnerAgreement]

/- The historical Java gate checks metadata and the raw endpoint/argument
   structural keys, which include caller context. Source path is deliberately
   not compared, because a domain clone has a different normalized path. -/
def oldGate (leftContext rightContext : List String)
    (leftMeta rightMeta : Metadata) (leftEndpoint rightEndpoint : String)
    (leftArguments rightArguments : List String) : Bool :=
  decide (leftContext = rightContext) &&
    decide (leftMeta = rightMeta ∧ leftEndpoint = rightEndpoint ∧ leftArguments = rightArguments)

theorem old_gate_rejects_distinct_context (leftContext rightContext : List String)
    (different : leftContext ≠ rightContext) (metadata : Metadata)
    (left right : String) (leftArgs rightArgs : List String) :
    oldGate leftContext rightContext metadata metadata left right leftArgs rightArgs = false := by
  simp [oldGate, different]

#print axioms atom_action_evaluates
#print axioms typed_cast_trans
#print axioms arguments_action_evaluates
#print axioms duplicate_payload_sound
#print axioms old_gate_rejects_distinct_context
end CallContextWeakening
