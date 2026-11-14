import SelectedPrimaryCongruence

/- A detached comparison forest may omit unreachable phases. Its source
   inventory remains intact. Live child groups and their typed payloads are
   unchanged; no individual branch or binding is identified by a display name. -/
namespace LivePhaseSupport
open SelectedPrimaryCongruence

def restrict (graph : Graph P) (live : List Nat) : Graph P :=
  fun index => if index ∈ live then graph index else none

def closed (graph : Graph P) (live : List Nat) : Bool :=
  live.all fun index => match graph index with
    | none => false
    | some node => node.children.all fun child => decide (child ∈ live)

theorem child_retained (graph : Graph P) (live : List Nat) (checked : closed graph live = true)
    (index : Nat) (member : index ∈ live) (node : Node P) (found : graph index = some node)
    (child : Nat) (edge : child ∈ node.children) : child ∈ live := by
  have h : ∀ child ∈ node.children, child ∈ live := by
    simpa [found, List.all_eq_true] using (List.all_eq_true.mp checked) index member
  exact h child edge

theorem live_lookup (graph : Graph P) (live : List Nat) (checked : closed graph live = true)
    (root : Nat) (member : root ∈ live) (path : List Nat) :
    walk (restrict graph live) root (primary path) = walk graph root (primary path) := by
  induction path generalizing root with
  | nil => simp [walk, primary, restrict, member]
  | cons index rest ih =>
    cases h : graph root with
    | none => simp [walk, primary, restrict, member, h]
    | some node =>
      cases hc : node.children[index]? with
      | none => simp [walk, primary, restrict, member, h, hc]
      | some next =>
        have present : next ∈ node.children := List.mem_of_getElem? hc
        have retained := child_retained graph live checked root member node h next present
        simpa [walk, primary, restrict, member, h, hc] using ih next retained

theorem complete_live_store (graph : Graph P) (live : List Nat)
    (checked : closed graph live = true) (root : Nat) (member : root ∈ live) :
    store (restrict graph live) root = store graph root := by
  funext path
  simp [store, live_lookup graph live checked root member path]

theorem selected_program_congruence [DecidableEq P] (graph : Graph P) (live : List Nat)
    (checked : closed graph live = true) (root : Nat) (member : root ∈ live)
    (program : List (DistanceDerivedTrace.Operation (List Nat) P)) :
    DistanceDerivedTrace.run (store (restrict graph live) root) program =
      DistanceDerivedTrace.run (store graph root) program := by
  rw [complete_live_store graph live checked root member]

/- The existing identity join applies to an authenticated live subset, not
   necessarily the entire historical phase inventory. Both presentations must
   cover the identical subset and retain the original typed records. -/
theorem subset_identity_join [DecidableEq I] [DecidableEq D]
    (original : Fin total → AuthenticatedPhaseTransport.Original I D)
    (live : Fin count → Fin total)
    (fastView certView : Fin count → AuthenticatedPhaseTransport.Original I D)
    (fast cert : AuthenticatedPhaseTransport.Reindex (Fin count) (Fin count))
    (hf : AuthenticatedPhaseTransport.authentic (original ∘ live) fastView fast = true)
    (hc : AuthenticatedPhaseTransport.authentic (original ∘ live) certView cert = true)
    (index : Fin count) :
    fastView index = certView ((AuthenticatedPhaseTransport.between fast cert).forward index) :=
  AuthenticatedPhaseTransport.authentic_join (original ∘ live) fastView certView fast cert hf hc index

def oldCompleteGate (sourceCount : Nat) (live : List Nat) : Bool :=
  decide (live.length = sourceCount)

theorem missing_live_child_rejected (payload : P) :
    closed (fun i => if i = 0 then some (Node.mk payload [1] []) else none) [0] = false := by
  simp [closed]

end LivePhaseSupport
