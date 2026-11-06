import Lean

namespace FeedbackLearning

-- Pure contracts for the new learning boundary, not a proof of PyTorch or Java.
structure Annotated (Metric TypeInfo : Type) where
  metric : Metric
  types : TypeInfo

theorem metadata_preserves_metric {M T : Type} (m : M) (a b : T) :
    (Annotated.mk m a).metric = (Annotated.mk m b).metric := rfl

structure Edge (Address : Type) where
  source : Address
  target : Address
  role : Nat
  position : Int
  deriving DecidableEq

def transport {A B : Type} (f : A → B) (e : Edge A) : Edge B :=
  ⟨f e.source, f e.target, e.role, e.position⟩

theorem edge_roundtrip {A B : Type} (f : A → B) (g : B → A)
    (inverse : ∀ a, g (f a) = a) (e : Edge A) :
    transport g (transport f e) = e := by
  cases e with | mk s t r p => simp [transport, inverse]

theorem role_retained {A B : Type} (f : A → B) (e : Edge A) :
    (transport f e).role = e.role := rfl

theorem position_retained {A B : Type} (f : A → B) (e : Edge A) :
    (transport f e).position = e.position := rfl

theorem multiplicity_retained {A B : Type} (f : A → B) (es : List (Edge A)) :
    (es.map (transport f)).length = es.length := by simp

structure Example (View Label Private : Type) where
  view : View
  label : Label
  privateData : Private

def input {V L P Tensor : Type} (encode : V → Tensor) (e : Example V L P) :=
  encode e.view

theorem label_private_noninterference {V L P T : Type} (encode : V → T)
    (v : V) (l1 l2 : L) (p1 p2 : P) :
    input encode (Example.mk v l1 p1) = input encode (Example.mk v l2 p2) := rfl

theorem prediction_noninterference {V L P T Action : Type} (encode : V → T)
    (policy : T → Action) (v : V) (l1 l2 : L) (p1 p2 : P) :
    policy (input encode (Example.mk v l1 p1)) =
    policy (input encode (Example.mk v l2 p2)) := rfl

def queryAllowed (used limit : Nat) := used < limit

theorem query_limit (used limit : Nat) (h : queryAllowed used limit) :
    used + 1 ≤ limit := by unfold queryAllowed at h; omega

def passGate (repairs target valid total : Nat) :=
  repairs ≥ target ∧ valid = total

theorem failed_gate_stops (r t v n : Nat) (h : ¬ passGate r t v n) :
    ¬ (r ≥ t ∧ v = n) := h

theorem below_threshold_not_pass (r t v n : Nat) (h : r < t) :
    ¬ passGate r t v n := by unfold passGate; omega

#print axioms metadata_preserves_metric
#print axioms edge_roundtrip
#print axioms role_retained
#print axioms position_retained
#print axioms multiplicity_retained
#print axioms label_private_noninterference
#print axioms prediction_noninterference
#print axioms query_limit
#print axioms failed_gate_stops
#print axioms below_threshold_not_pass
end FeedbackLearning
