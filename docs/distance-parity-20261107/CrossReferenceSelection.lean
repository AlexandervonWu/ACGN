import JointDeclarationPathSelection
import EndpointCanonicalContracts
import OrbitMetricTransport
import GroupedPaidOrbit
import DisjointGroupPermutation
import NormalizedDeclarationDomain
import StructuralDeclarationTyping

namespace CrossReferenceSelection
open EndpointCanonicalContracts

-- A domain key is interpreted with its ordered, source-owned dependencies.
-- Equal keys alone do not identify the environment used by the domain.
structure Frame where
  owner : Nat
  phase : Nat
  type : Nat
  domain : Nat
  dependencies : List Nat
  deriving DecidableEq

def header (f : Frame) := (f.owner, f.phase, f.type, f.domain)
def authenticOrbit (frames : Nat → Frame) (p : Permutation) : Prop :=
  ∀ i, header (frames (p.forward i)) = header (frames i) ∧
    (frames i).dependencies.map p.forward = (frames (p.forward i)).dependencies

def domainHolds (frames : Nat → Frame) (interpret : Nat → List V → V → Prop)
    (env : Nat → V) (i : Nat) :=
  interpret (frames i).domain ((frames i).dependencies.map env) (env i)

theorem dependency_reads (frames : Nat → Frame) (p : Permutation)
    (h : authenticOrbit frames p) (env : Nat → V) (i : Nat) :
    (frames (p.forward i)).dependencies.map (fun j => env (p.backward j)) =
      (frames i).dependencies.map env := by
  rw [← (h i).2]
  simp [List.map_map, Function.comp_def, p.leftInverse]

theorem domain_transport (frames : Nat → Frame) (p : Permutation)
    (h : authenticOrbit frames p) (interpret : Nat → List V → V → Prop)
    (env : Nat → V) (i : Nat) :
    domainHolds frames interpret (fun j => env (p.backward j)) (p.forward i) ↔
      domainHolds frames interpret env i := by
  have domain : (frames (p.forward i)).domain = (frames i).domain :=
    congrArg (fun x => x.2.2.2) (h i).1
  simp only [domainHolds, domain, dependency_reads frames p h, p.leftInverse]

theorem all_domains_transport (frames : Nat → Frame) (p : Permutation)
    (h : authenticOrbit frames p) (interpret : Nat → List V → V → Prop)
    (env : Nat → V) :
    (∀ i, domainHolds frames interpret (fun j => env (p.backward j)) i) ↔
      ∀ i, domainHolds frames interpret env i := by
  constructor
  · intro all i
    exact (domain_transport frames p h interpret env i).mp (all (p.forward i))
  · intro all j
    have step := (domain_transport frames p h interpret env (p.backward j)).mpr (all _)
    simpa only [p.rightInverse] using step

theorem owner_phase_type (frames : Nat → Frame) (p : Permutation)
    (h : authenticOrbit frames p) (i : Nat) :
    (frames (p.forward i)).owner = (frames i).owner ∧
    (frames (p.forward i)).phase = (frames i).phase ∧
    (frames (p.forward i)).type = (frames i).type := by
  have eq := (h i).1
  exact ⟨congrArg (fun x => x.1) eq, congrArg (fun x => x.2.1) eq,
    congrArg (fun x => x.2.2.1) eq⟩

-- Body transport reuses the existing environment lemma. Quantification uses
-- the same bijective valuation transport; no domain or imported owner is lost.
theorem body_transport (owner : Nat) (p : Permutation) (env : Ref → V) (e : Expr V) :
    eval (transport owner p.backward env) (rename owner p.forward e) = eval env e :=
  eval_rename owner p env e

-- The extracted inv7 chain has dependency owners 0 and 1, although both
-- relative domain encodings contain dependency/0. Swapping 1 and 2 is invalid.
def swap12 (i : Nat) := if i = 1 then 2 else if i = 2 then 1 else i
def chainDeps (i : Nat) : List Nat := if i = 1 then [0] else if i = 2 then [1] else []
theorem chain_swap_rejected : (chainDeps 1).map swap12 ≠ chainDeps (swap12 1) := by decide
theorem shared_dependency_permitted : ([0] : List Nat).map swap12 = [0] := by decide
theorem moved_dependency_checked : ([1] : List Nat).map swap12 ≠ [1] := by decide

-- An explicit relational countermodel to exchanging reads while leaving a
-- dependent declaration chain fixed, rather than assuming the failed law.
def edge (a b : Fin 3) : Prop := a.val + 1 = b.val
theorem dependent_body_swap_not_sound :
    (∀ a b c : Fin 3, edge a b → edge b c → edge b c) ∧
    ¬ (∀ a b c : Fin 3, edge a b → edge b c → edge c b) := by
  constructor
  · intro _ _ _ _ h; exact h
  · intro h
    have bad := h 0 1 2 (by simp [edge]) (by simp [edge])
    have impossible : ¬ edge (2 : Fin 3) 1 := by simp [edge]
    exact impossible bad

open SelectedDeclarationCompletion SelectedDeclarationPathTransport

-- Reuse the complete selected program, including zero keeps and one-sided
-- steps. Import completion is not permission to undo a paid deletion.
theorem import_no_deleted_read (path : List Step) (residual : List Link) (a : Binding)
    (owned : a.vectorIndex ∈ (sources path).map Binding.vectorIndex)
    (unpaired : a.vectorIndex ∉ (links path).map (fun p => p.1.vectorIndex)) :
    ∀ link ∈ JointDeclarationPathSelection.complete path residual,
      link.1.vectorIndex ≠ a.vectorIndex :=
  JointDeclarationPathSelection.one_sided_source_stays_unmapped path residual a owned unpaired

theorem import_no_inserted_read (path : List Step) (residual : List Link) (b : Binding)
    (owned : b.vectorIndex ∈ (targets path).map Binding.vectorIndex)
    (unpaired : b.vectorIndex ∉ (links path).map (fun p => p.2.vectorIndex)) :
    ∀ link ∈ JointDeclarationPathSelection.complete path residual,
      link.2.vectorIndex ≠ b.vectorIndex :=
  JointDeclarationPathSelection.one_sided_target_stays_unmapped path residual b owned unpaired

-- Observation is applied after deterministic selection; adding a receipt
-- must not change the chosen candidate or any later refinement of it.
def observe (capture : Bool) (emit : P → R) (selected : P) : P × Option R :=
  (selected, if capture then some (emit selected) else none)

theorem capture_erasure (emit : P → R) (selected : P) (refine : P → Q) :
    refine (observe true emit selected).1 = refine (observe false emit selected).1 := rfl

theorem same_selection (first : OrbitMetricTransport.Path)
    (rest : List OrbitMetricTransport.Path) (emit : OrbitMetricTransport.Path → R) :
    (observe true emit (OrbitMetricTransport.select first rest)).1 =
      (observe false emit (OrbitMetricTransport.select first rest)).1 := rfl

-- A caller may request capture without requesting an exported map. Both uses
-- need the same selected witness; absence of either use is not absence of both.
def recordedSelection (capture exportMap : Bool) (selected : P) : P × Option P :=
  observe (capture || exportMap) id selected

theorem capture_has_selected_witness (exportMap : Bool) (selected : P) :
    (recordedSelection true exportMap selected).2 = some selected := rfl

theorem map_has_selected_witness (capture : Bool) (selected : P) :
    (recordedSelection capture true selected).2 = some selected := by
  cases capture <;> rfl

theorem recorded_selection_erasure (capture exportMap : Bool) (selected : P)
    (refine : P → Q) :
    refine (recordedSelection capture exportMap selected).1 = refine selected := rfl

theorem numeric_only_needs_no_holder (selected : P) :
    (recordedSelection false false selected).2 = none := rfl

theorem captured_path_valid (valid : OrbitMetricTransport.Path → Prop)
    (first : OrbitMetricTransport.Path) (rest : List OrbitMetricTransport.Path)
    (all : ∀ p ∈ first :: rest, valid p) (exportMap : Bool) :
    ∃ selected, (recordedSelection true exportMap
      (OrbitMetricTransport.select first rest)).2 = some selected ∧ valid selected :=
  ⟨_, rfl, OrbitMetricTransport.selected_valid valid first rest all⟩

-- The source has nested Person/Course ALL blocks and a regrouped target. The
-- same-phase alignment caller passes no exported-map accumulator during capture.
def captureHolderSourceHash := "01048dce151c0e7f6312a022024f272746169e4d2c80d31adab84bd2b3c6f1fe"
theorem exact_old_capture_holder_missing (selected : P) :
    (observe false id selected).2 = none ∧
    (recordedSelection true false selected).2 = some selected := ⟨rfl, rfl⟩

theorem capture_never_substitutes_witness (capture exportMap : Bool) (selected forged : P)
    (different : selected ≠ forged) :
    (recordedSelection capture exportMap selected).2 ≠ some forged := by
  cases capture <;> cases exportMap <;> simp_all [recordedSelection, observe]

-- Equal intermediate costs are not enough when the selected witness controls
-- a subsequent stage. This is why capture-only tie breakers are unsound.
theorem equal_prefix_cost_not_enough :
    (13 : Nat) = 13 ∧ (min 13 11 : Nat) ≠ min 13 13 := by decide

def compose (p q : Permutation) : Permutation :=
  ⟨fun i => q.forward (p.forward i), fun i => p.backward (q.backward i),
   fun i => by simp [q.leftInverse, p.leftInverse],
   fun i => by simp [p.rightInverse, q.rightInverse]⟩

theorem orbit_closed (frames : Nat → Frame) (p q : Permutation)
    (hp : authenticOrbit frames p) (hq : authenticOrbit frames q) :
    authenticOrbit frames (compose p q) := by
  intro i
  refine ⟨(hq (p.forward i)).1.trans (hp i).1, ?_⟩
  change (frames i).dependencies.map (fun j => q.forward (p.forward j)) =
    (frames (q.forward (p.forward i))).dependencies
  rw [← (hq (p.forward i)).2, ← (hp i).2]
  simp [List.map_map, Function.comp_def]

theorem composed_charge (left right : Nat → Nat) (p q : Permutation)
    (lp : ∀ i, left (p.forward i) = left i)
    (rq : ∀ i, right (q.forward i) = right i) (edit : GroupedPaidOrbit.Edit) :
    GroupedPaidOrbit.charge left right (GroupedPaidOrbit.move p.forward q.forward edit) =
      GroupedPaidOrbit.charge left right edit :=
  GroupedPaidOrbit.actual_declaration_action_cost_retained left right p.forward q.forward lp rq edit

-- coursesOld/correct/AngG4RJCPYrN4n4kr_inv10.als, SHA256 below:
-- all p,c,g:univ. A three-cycle composes two already admitted swaps.
def univSourceHash := "9f45457c26ad389ed3c25105414afee79e906ef53381dd537ba4653a769f5b98"
def oldThreeSlotOrders : List (List Nat) := [[0,1,2],[1,0,2],[2,1,0],[0,2,1]]
theorem exact_old_three_cycle_rejection : [2,0,1] ∉ oldThreeSlotOrders := by decide
theorem three_cycle_general {A : Type} (domain : A → Prop) (body : A → A → A → Prop) :
    (∀ a, domain a → ∀ b, domain b → ∀ c, domain c → body a b c) ↔
      ∀ c, domain c → ∀ a, domain a → ∀ b, domain b → body a b c := by
  constructor
  · intro h c hc a ha b hb; exact h a ha b hb c hc
  · intro h a ha b hb c hc; exact h c hc a ha b hb
theorem univ_three_cycle {Atom : Type} (body : Atom → Atom → Atom → Prop) :
    (∀ p c g, body p c g) ↔ ∀ g p c, body p c g := by
  constructor <;> intro h a b c
  · exact h b c a
  · exact h c a b

-- Spelling is deliberately not a binding identity. The vector, source hash,
-- owner, phase, occurrence and typed payload are checked before lookup.
theorem source_owned_lookup (census : List Binding) (index : Nat) (claimed : Binding)
    (h : associated census index claimed = true) : census[index]? = some claimed :=
  (associated_exact census index claimed h).1

def branchOrigin : Origin :=
  ⟨"dc9aed3fb24289a896719bd8775f7bdd030b6e7539a0b26c5d6d24bdc8bba837",
   "inv15", "root/predicate[0]/or[1]/decl[0]@pos", "", 0, "MATRIX", [], [],
   "Person", "alloy-binder-domain/Person", "ALL", "ONE", 0⟩
def branchA : Binding := ⟨branchOrigin,0,0,0⟩
def branchB : Binding := ⟨{branchOrigin with occurrence := "root/predicate[0]/or[2]/decl[0]@pos"},1,1,1⟩
theorem old_alias_gate_rejects : ¬ (["p1","p1"] : List String).Nodup := by decide
theorem distinct_source_slots_accept :
    associated [branchA,branchB] 0 branchA = true ∧
    associated [branchA,branchB] 1 branchB = true ∧ branchA ≠ branchB := by decide
theorem swapped_source_slot_rejects : associated [branchA,branchB] 0 branchB = false := by decide
theorem forged_owner_rejects :
    associated [branchA,branchB] 1 {branchB with origin.owner := "foreign"} = false := by decide

-- Empty paid correspondence does not imply an empty orbit of surviving keeps.
-- The two Person slots in this target are one independent ALL block.
def keepOrigin : Origin := {branchOrigin with
  sourceHash := "a9f6ce1943c97501e1a064636d4ddfae0cef4631c661fec022ba25f4cd32aae8"
  predicate := "inv14"
  occurrence := "root/predicate[0]/decl[0]@pos"}
def keep0 : Binding := ⟨keepOrigin,0,2,0⟩
def keep1 : Binding := ⟨keepOrigin,1,3,1⟩
def zeroPath : List Step := [.pair keep0 keep1, .pair keep1 keep0]
theorem empty_paid_still_has_links : paid zeroPath = [] ∧
    links zeroPath = [(keep0,keep1),(keep1,keep0)] ∧ cost zeroPath = 0 := by decide
theorem exchanged_keeps_replay : replay [keep0,keep1] zeroPath = some ([keep1,keep0],0) := by decide
theorem independent_keep_exchange {Person : Type} (body : Person → Person → Prop) :
    (∀ p1 p2, body p1 p2) ↔ ∀ p2 p1, body p1 p2 := by
  simpa using SeparatePrefixExchange.independent_all_exchange (fun _ => True) (fun _ => True) body

-- Two actual minimum programs for ONE User, ALL Institution, ALL Work versus
-- ALL User, ALL Work. Choosing the first DP backtrace alone loses a paid route.
def userOrigin : Origin := {branchOrigin with
  sourceHash := "e6d4b1dd07093a41c7776638e045c0fde24d1b6567c8400082ec13be4cde0cd4"
  predicate := "inv2"
  occurrence := "root/predicate[0]/decl[0]@pos"
  exactType := "User", domain := "alloy-binder-domain/User", quantifier := "ONE"}
def u : Binding := ⟨userOrigin,0,0,0⟩
def institution : Binding := ⟨{userOrigin with
  exactType := "Institution", quantifier := "ALL"
  occurrence := "root/predicate[0]/body[1]/decl[0]@pos"
  domain := "alloy-binder-domain/Institution"},1,1,1⟩
def work : Binding := ⟨{userOrigin with
  exactType := "Work", quantifier := "ALL", dependencies := [0]
  occurrence := "root/predicate[0]/body[1]/decl[1]@pos"
  domain := "JOIN(dependency/0:User,profile:User->Work)"},2,2,2⟩
def targetUser : Binding := ⟨{userOrigin with
  sourceHash := "232c4d61a5461e568b087ade797b2b10c68f4fffeaa0592be362b677ad751276"
  quantifier := "ALL"},0,0,0⟩
def targetWork : Binding := ⟨{work.origin with
  sourceHash := targetUser.origin.sourceHash
  occurrence := "root/predicate[0]/decl[1]@pos"},1,1,1⟩
def firstPath : List Step := [.delete u,.pair institution targetUser,.pair work targetWork]
def alternatePath : List Step := [.pair u targetUser,.delete institution,.pair work targetWork]
theorem equal_declaration_paths :
    replay [u,institution,work] firstPath = some ([targetUser,targetWork],2) ∧
    replay [u,institution,work] alternatePath = some ([targetUser,targetWork],2) := by decide
theorem first_path_misses_typed_route : (u,targetUser) ∉ links firstPath ∧
    (u,targetUser) ∈ paid alternatePath ∧ u.origin.exactType = targetUser.origin.exactType ∧
    u.origin.phase = targetUser.origin.phase ∧ u.origin.owner = targetUser.origin.owner := by
  simp [firstPath, alternatePath, links, paid, sameTuple, u, institution, work,
    targetUser, targetWork, userOrigin, branchOrigin]

-- Enumeration adds only independently checked paths; the selected member and
-- its exact payments survive. No claim follows from a smaller scalar alone.
theorem checked_path_selection (valid : OrbitMetricTransport.Path → Prop)
    (first : OrbitMetricTransport.Path) (rest : List OrbitMetricTransport.Path)
    (checked : ∀ path ∈ first :: rest, valid path) :
    valid (OrbitMetricTransport.select first rest) :=
  OrbitMetricTransport.selected_valid valid first rest checked

-- Prefix normalization can give separate source declarations one presentation
-- path. Group validation must use the issued declaration identity, not that path.
structure IssuedSlot where
  owner : Nat
  phase : Nat
  declaration : Nat
  slot : Nat
  payload : String
  presentation : String
  deriving DecidableEq

def sourceGroup (slots : List IssuedSlot) (q : IssuedSlot) :=
  slots.filter (fun r => r.owner == q.owner && r.phase == q.phase &&
    r.declaration == q.declaration)

theorem source_group_exact (slots : List IssuedSlot) (q r : IssuedSlot) :
    r ∈ sourceGroup slots q ↔ r ∈ slots ∧
      r.owner = q.owner ∧ r.phase = q.phase ∧ r.declaration = q.declaration := by
  simp [sourceGroup, and_assoc]

theorem grouping_preserves_checks (slots : List IssuedSlot) (check : IssuedSlot → Prop) :
    (∀ q ∈ slots, ∀ r ∈ sourceGroup slots q, check r) ↔ ∀ r ∈ slots, check r := by
  constructor
  · intro h r hr
    exact h r hr r ((source_group_exact slots r r).mpr ⟨hr,rfl,rfl,rfl⟩)
  · intro h _ _ r hr
    exact h r ((source_group_exact slots _ r).mp hr).1

-- coursesNew/correct/vJ6jnsfJKnboP76GA_inv5.als. Project and Person
-- originate in different declarations despite a common normalized owner path.
def mergedPrefixHash := "ec8f6ee4b2ecee57aca5642abe1d6f6e513bfe54fc7b82c83c8b89159a7338ed"
def projectSlot : IssuedSlot := ⟨0,0,0,0,"Project","and[0]/decl[0]"⟩
def personSlot : IssuedSlot := ⟨0,0,1,0,"Person","and[0]/decl[0]"⟩
theorem presentation_group_rejects_sound_source :
    projectSlot.presentation = personSlot.presentation ∧
    projectSlot.payload ≠ personSlot.payload ∧
    sourceGroup [projectSlot,personSlot] projectSlot = [projectSlot] ∧
    sourceGroup [projectSlot,personSlot] personSlot = [personSlot] := by decide

theorem source_group_rejects_foreign_owner :
    {personSlot with owner := 1} ∉ sourceGroup [projectSlot,personSlot] personSlot := by decide

-- The tuple example above is not a cross-phase equivalence. These are the
-- captured dependent guards in phase 0; the unmatched future is a paid tree
-- deletion, not a licence to rebind its imports into the other endpoint.
def guardTransport (path : List Step) (a b depA depB : Binding) : Prop :=
  (a,b) ∈ links path ∧ (depA,depB) ∈ links path ∧
  a.origin.domain = b.origin.domain ∧
  a.origin.dependencies = [depA.ordinal] ∧ b.origin.dependencies = [depB.ordinal] ∧
  a.origin.owner = depA.origin.owner ∧ b.origin.owner = depB.origin.owner ∧
  a.origin.phase = depA.origin.phase ∧ b.origin.phase = depB.origin.phase

theorem concrete_profile_guard : guardTransport alternatePath work targetWork u targetUser := by
  simp [guardTransport, alternatePath, links, work, targetWork, u, targetUser, userOrigin]

theorem first_path_cannot_borrow_deleted_user :
    ¬ guardTransport firstPath work targetWork u targetUser := by
  simp [guardTransport,firstPath,links,work,targetWork,u,targetUser,institution,userOrigin]

theorem forged_profile_domain_rejected :
    ¬ guardTransport alternatePath work {targetWork with origin :=
      {targetWork.origin with domain := "alloy-binder-domain/User"}} u targetUser := by
  simp [guardTransport,work,targetWork]

theorem foreign_profile_dependency_rejected :
    ¬ guardTransport alternatePath work targetWork institution targetUser := by
  simp [guardTransport,work,institution]

theorem foreign_profile_owner_rejected :
    ¬ guardTransport alternatePath work targetWork
      {u with origin := {u.origin with owner := "foreign"}} targetUser := by
  simp [guardTransport,work,u,userOrigin,branchOrigin]

-- The selected, typed User and Work reads carry the same profile relation.
-- This law does not assume equivalence of the paid ONE/ALL predicates.
theorem profile_guard_congruence (profile : U → W → Prop)
    (sourceUser targetUser : U) (sourceWork targetWork : W)
    (userRead : sourceUser = targetUser) (workRead : sourceWork = targetWork) :
    profile sourceUser sourceWork ↔ profile targetUser targetWork := by
  rw [userRead,workRead]

-- Retained local disjoint scopes are checked without hoisting or erasing them.
-- The predicate for valuations includes both the domain and injectivity guard.
def localOldGate (opcode : String) (group : Nat) := opcode = "GENERICRELDECL" ∧ group = 0
def localGroupGate (opcode : String) (groups : List Nat) : Prop :=
  (opcode = "GENERICRELDECL" ∧ ∀ g ∈ groups, g = 0) ∨
  (opcode = "DISJ" ∧ ∃ g, g > 0 ∧ ∀ h ∈ groups, h = g)
def retainedDisjointHash := "dff176fa00eded4109b5d08872b134a5b5ddeebea215acf3a64fcc6566e01d2c"
theorem retained_disjoint_old_rejection : ¬ localOldGate "DISJ" 1 := by simp [localOldGate]
theorem retained_disjoint_new_admission : localGroupGate "DISJ" [1,1] := by
  exact Or.inr ⟨rfl,1,by decide,by simp⟩
theorem mixed_disjoint_group_rejected : ¬ localGroupGate "DISJ" [1,2] := by
  simp [localGroupGate]
theorem erased_disjoint_guard_rejected : ¬ localGroupGate "GENERICRELDECL" [1,1] := by
  simp [localGroupGate]
theorem retained_disjoint_all (p : DisjointGroupPermutation.Permutation I)
    (domain : A → Prop) (body : (I → A) → Prop) :
    (∀ v, DisjointGroupPermutation.valid domain v → body v) ↔
      ∀ v, DisjointGroupPermutation.valid domain v →
        body (DisjointGroupPermutation.reindex p v) :=
  DisjointGroupPermutation.all_group_permutation p domain body
theorem retained_disjoint_some (p : DisjointGroupPermutation.Permutation I)
    (domain : A → Prop) (body : (I → A) → Prop) :
    (∃ v, DisjointGroupPermutation.valid domain v ∧ body v) ↔
      ∃ v, DisjointGroupPermutation.valid domain v ∧
        body (DisjointGroupPermutation.reindex p v) :=
  DisjointGroupPermutation.some_group_permutation p domain body

-- A full homogeneous matching class has redundant two-sided witnesses.
-- Absorb its left permutation into the right through the original matching.
-- Java checks closure, bijection and homogeneous paid/keep membership first.
def relative (matching left right : Permutation) : Permutation :=
  compose (compose (compose
    ⟨matching.backward, matching.forward, matching.rightInverse, matching.leftInverse⟩
    ⟨left.backward, left.forward, left.rightInverse, left.leftInverse⟩) matching) right
theorem relative_correspondence (matching left right : Permutation) (i : Nat) :
    (relative matching left right).forward (matching.forward (left.forward i)) =
      right.forward (matching.forward i) := by
  simp [relative,compose,matching.leftInverse,left.leftInverse]
theorem relative_paid_membership (left : Permutation)
    (paid : Nat → Prop) (stable : ∀ i, paid (left.forward i) ↔ paid i) (i : Nat) :
    paid (left.forward i) ↔ paid i := stable i

def negatedOneSourceHash := "1e41c9ad5917b6e3a558c18f01791201a8e653eb9688e8db7e6d3ca9dc63e24e"
def localQuantifier (negated : Bool) (head : String) : String :=
  if negated && head == "ONE" then "NOTONE"
  else if negated && head == "LONE" then "NOTLONE" else head
theorem negated_local_old_rejection : ("ONE" : String) ≠ "NOTONE" := by decide
theorem negated_local_exact_admission : localQuantifier true "ONE" = "NOTONE" := by decide
theorem positive_local_not_relabelled : localQuantifier false "ONE" ≠ "NOTONE" := by decide
theorem negated_one_transport (f g : A → A) (fg : ∀ x, f (g x) = x)
    (gf : ∀ x, g (f x) = x) (p : A → Prop) :
    (¬ one (fun x => p (f x))) ↔ ¬ one p :=
  not_congr (one_transport f g fg gf p)
theorem negated_lone_transport (f g : A → A) (fg : ∀ x, f (g x) = x)
    (gf : ∀ x, g (f x) = x) (p : A → Prop) :
    (¬ lone (fun x => p (f x))) ↔ ¬ lone p :=
  not_congr (lone_transport f g fg gf p)
theorem actual_negated_owner (posts : User → Ad → Prop) (good : User → Prop) :
    (∀ u, one (posts u) → good u) ↔ ∀ u, ¬ one (posts u) ∨ good u := by
  classical
  constructor
  · intro h u
    by_cases hp : one (posts u)
    · exact Or.inr (h u hp)
    · exact Or.inl hp
  · intro h u hp
    exact (h u).resolve_left (fun hn => hn hp)

-- Congruence extends the existing carrier-intersection law through difference;
-- it does not remove the declaration guard or move it to a future phase.
theorem difference_domain_congruence (left before after : Rel A)
    (step : NormalizedDeclarationDomain.Derivation before after) :
    difference left before = difference left after := by
  rw [NormalizedDeclarationDomain.derivation_sound step]

def nestedDomainHash := "f6e12b0dda0e203b1c2cd3d39f5b5d2638012e935a2c41e51081202845f6f4a7"
theorem nested_domain_old_gate_rejection : ("MINUS" == "INTERSECT") = false := by decide
theorem nested_dynamic_domain (file protectedSet : Env → Nat → A → Prop)
    (env : Env) (time : Nat) :
    difference (file env time)
      (intersection (file env time) (NormalizedDeclarationDomain.declaredSubset file protectedSet env time)) =
    difference (file env time) (NormalizedDeclarationDomain.declaredSubset file protectedSet env time) :=
  difference_domain_congruence _ _ _
    (NormalizedDeclarationDomain.dynamic_source_derivation file protectedSet env time)

theorem nested_domain_same_phase_guard (file protectedSet : Env → Nat → A → Prop)
    (env : Env) (time : Nat) (value : A) (context : PaidSlotGuardAuthentication.Context) :
    context.eval (¬ difference (file env time)
      (intersection (file env time) (NormalizedDeclarationDomain.declaredSubset file protectedSet env time)) value) ↔
    context.eval (¬ difference (file env time)
      (NormalizedDeclarationDomain.declaredSubset file protectedSet env time) value) := by
  rw [nested_dynamic_domain]

-- A one-entry cache is local to fixed endpoint, owner/phase, payment and capture
-- contexts. Its payload includes the selected map and decisions, not just cost.
def reuseMatrix [DecidableEq K] (evaluate : K → V) (key : K)
    (cached : Option (K × V)) : V :=
  match cached with
  | some (old, value) => if old = key then value else evaluate key
  | none => evaluate key

theorem reuse_matrix_exact [DecidableEq K] (evaluate : K → V) (key : K)
    (cached : Option (K × V))
    (issued : ∀ old value, cached = some (old,value) → value = evaluate old) :
    reuseMatrix evaluate key cached = evaluate key := by
  cases cached with
  | none => rfl
  | some pair =>
    rcases pair with ⟨old,value⟩
    simp only [reuseMatrix]
    split
    · rename_i equal
      simpa [equal] using issued old value rfl
    · rfl

-- An absent map entry is not evidence that its slot is absent from the body.
-- Coverage is tested on each aligned phase, including reads on either side.
def mappedTarget (mapping : List (Nat × Nat)) (source : Nat) : Option Nat :=
  (mapping.find? (fun p => p.1 == source)).map Prod.snd

def liveLinksPresent (sourceReads targetReads : List Nat)
    (links mapping : List (Nat × Nat)) : Bool :=
  links.all fun p => if p.1 ∈ sourceReads ∨ p.2 ∈ targetReads then
    mappedTarget mapping p.1 == some p.2 else true

-- The map here is projected to entries touching the selected declaration
-- domain. Java retains its separate handling of unrelated residual locals.
def oldMapAgrees (links mapping : List (Nat × Nat)) : Bool :=
  mapping.all (fun p => links.contains p)

def attainedReadMap (sourceReads targetReads : List Nat)
    (links mapping : List (Nat × Nat)) : Bool :=
  oldMapAgrees links mapping && liveLinksPresent sourceReads targetReads links mapping

theorem live_link_lookup (sourceReads targetReads : List Nat)
    (links mapping : List (Nat × Nat)) (source target : Nat)
    (checked : liveLinksPresent sourceReads targetReads links mapping = true)
    (paired : (source,target) ∈ links)
    (live : source ∈ sourceReads ∨ target ∈ targetReads) :
    mappedTarget mapping source = some target := by
  have h := List.all_eq_true.mp checked (source,target) paired
  simpa [live] using h

theorem live_read_transport (sourceReads targetReads : List Nat)
    (links mapping : List (Nat × Nat)) (source target : Nat) (values : Nat → V)
    (checked : liveLinksPresent sourceReads targetReads links mapping = true)
    (paired : (source,target) ∈ links)
    (live : source ∈ sourceReads ∨ target ∈ targetReads) :
    (mappedTarget mapping source).map values = some (values target) := by
  rw [live_link_lookup sourceReads targetReads links mapping source target checked paired live]
  rfl

theorem attainment_retains_old_checks (sourceReads targetReads : List Nat)
    (links mapping : List (Nat × Nat))
    (checked : attainedReadMap sourceReads targetReads links mapping = true) :
    oldMapAgrees links mapping = true := by
  have both : oldMapAgrees links mapping = true ∧
      liveLinksPresent sourceReads targetReads links mapping = true := by
    simpa only [attainedReadMap, Bool.and_eq_true] using checked
  exact both.1

theorem unread_links_need_no_matrix_map (links : List (Nat × Nat)) :
    attainedReadMap [] [] links [] = true := by
  simp [attainedReadMap, oldMapAgrees, liveLinksPresent]

-- inv10: Component c; Component p in c.parts & Component; p is read in
-- phase zero and AFTER. inv10c: Component c; Product p in c.parts, phase zero.
def importReadOrigin : Origin := {branchOrigin with
  sourceHash := "8d3b67a8beae03531e2e9a40fabf94e3a7ddd82e661eb0f72a3f5705d2c2d66b"
  predicate := "inv10", occurrence := "root/predicate[0]/decl[0]@pos"
  exactType := "Component", domain := "alloy-binder-domain/Component"}
def importReadC : Binding := ⟨importReadOrigin,0,0,0⟩
def importReadP : Binding := ⟨{importReadOrigin with
  occurrence := "root/predicate[0]/body[1]/decl[0]@pos", dependencies := [0]
  domain := "INTERSECT(JOIN(dependency/0:Component,parts:Product->Product),Component)"},1,1,1⟩
def importReadTargetC : Binding := ⟨{importReadOrigin with predicate := "inv10c"},0,0,0⟩
def importReadTargetP : Binding := ⟨{importReadP.origin with
  predicate := "inv10c"
  occurrence := "root/predicate[0]/decl[1]@pos", exactType := "Product"
  domain := "JOIN(dependency/0:Component,parts:Product->Product)"},1,1,1⟩
def importReadPath : List Step :=
  [.pair importReadC importReadTargetC, .pair importReadP importReadTargetP]
theorem concrete_paid_import_program :
    replay [importReadC,importReadP] importReadPath =
      some ([importReadTargetC,importReadTargetP],1) := by decide

theorem exact_old_missing_live_read_accepted :
    oldMapAgrees [(0,0),(1,1)] [(0,0)] = true ∧
    attainedReadMap [0,1] [0,1] [(0,0),(1,1)] [(0,0)] = false := by decide
theorem actual_live_import_accepted :
    attainedReadMap [0,1] [0,1] [(0,0),(1,1)] [(0,0),(1,1)] = true := by decide
theorem target_only_live_read_required :
    attainedReadMap [] [1] [(0,0),(1,1)] [(0,0)] = false := by decide
theorem substituted_live_read_rejected :
    attainedReadMap [0,1] [0,1] [(0,0),(1,1)] [(0,0),(1,0)] = false := by decide
theorem one_sided_read_not_resurrected :
    attainedReadMap [0,1] [0] [(0,0)] [(0,0),(1,0)] = false := by decide

-- Quotienting a complete homogeneous class preserves its relative map, not
-- the literal source/target presentation. Retain a checked prior witness first.
def sourceRelative (matching left right : Permutation) : Permutation :=
  compose (compose (compose matching (reverse right)) (reverse matching)) left

theorem source_relative_correspondence (matching left right : Permutation) (i : Nat) :
    (sourceRelative matching left right).forward
      (matching.backward (right.forward (matching.forward i))) = left.forward i := by
  simp [sourceRelative, compose, reverse, matching.rightInverse,
    matching.leftInverse, right.leftInverse]

theorem source_relative_reverse (matching left right : Permutation) (j : Nat) :
    right.forward (matching.forward
      (left.backward ((sourceRelative matching left right).forward j))) =
        matching.forward j := by
  simp [sourceRelative, compose, reverse, left.leftInverse,
    matching.rightInverse, right.rightInverse]

theorem select_retains_attaining_first (first : OrbitMetricTransport.Path)
    (rest : List OrbitMetricTransport.Path)
    (minimum : ∀ p ∈ rest, OrbitMetricTransport.cost first ≤ OrbitMetricTransport.cost p) :
    OrbitMetricTransport.select first rest = first := by
  induction rest with
  | nil => rfl
  | cons p ps ih =>
    have no : ¬ OrbitMetricTransport.cost p < OrbitMetricTransport.cost first :=
      Nat.not_lt.mpr (minimum p (by simp))
    simp only [OrbitMetricTransport.select, OrbitMetricTransport.choose, ite_eq_right no]
    exact ih (fun q h => minimum q (by simp [h]))

theorem retained_checked_minimum (prior first : OrbitMetricTransport.Path)
    (rest : List OrbitMetricTransport.Path)
    (attains : OrbitMetricTransport.cost prior =
      OrbitMetricTransport.cost (OrbitMetricTransport.select first rest)) :
    OrbitMetricTransport.select prior (first :: rest) = prior := by
  apply select_retains_attaining_first
  intro p member
  rw [attains]
  exact OrbitMetricTransport.minimum_le_selected first rest p member

-- The source receipt has two independently lifted Track slots and an unrelated
-- Semaphore deletion. Junction and succs guards remain in the matrix, not erased.
def trainOrigin : Origin := {branchOrigin with
  sourceHash := "cf94ab1f6df091ef70a2d6b1db9d5496f0fcb32709d527dd16892f1e2430c5c7"
  predicate := "inv10", occurrence := "root/predicate[0]/decl[0]@pos"
  exactType := "Track", domain := "alloy-binder-domain/Track"}
def trainT : Binding := ⟨trainOrigin,0,0,1⟩
def trainJ : Binding := ⟨{trainOrigin with occurrence := "root/predicate[0]/decl[1]@pos"},1,1,2⟩
def trainS : Binding := ⟨{trainOrigin with
  occurrence := "root/predicate[0]/decl[2]@pos"
  exactType := "Semaphore", domain := "alloy-binder-domain/Semaphore"},2,2,0⟩
def trainTargetJ : Binding := ⟨{trainOrigin with predicate := "inv10c"},0,0,0⟩
def trainTargetT : Binding := ⟨{trainJ.origin with predicate := "inv10c"},1,1,1⟩
def trainRetainedPath : List Step :=
  [.delete trainS, .pair trainJ trainTargetJ, .pair trainT trainTargetT]
theorem train_retained_program :
    replay [trainS,trainJ,trainT] trainRetainedPath = some ([trainTargetJ,trainTargetT],1) ∧
    paid trainRetainedPath = [] := by decide

def trainFrames (i : Nat) : Frame :=
  if i < 2 then ⟨0,0,0,0,[]⟩ else ⟨0,0,1,1,[]⟩
theorem train_source_orbit_authentic : authenticOrbit trainFrames swap := by
  intro i
  by_cases h0 : i = 0
  · subst i; decide
  by_cases h1 : i = 1
  · subst i; decide
  have outside : 2 ≤ i := by omega
  simp [trainFrames, swap, slots_outside_block_fixed i outside, Nat.not_lt.mpr outside]

def oldQuotientSource (p : Permutation) : Prop := ∀ i < 2, p.forward i = i
theorem old_quotient_rejects_retained_source : ¬ oldQuotientSource swap := by
  intro h
  have impossible : (1 : Nat) = 0 := by simpa [swap,swap01] using h 0 (by decide)
  omega

theorem train_same_map_different_presentation :
    mappedTarget [(0,1),(1,0)] 0 = mappedTarget [(1,0),(0,1)] 0 ∧
    mappedTarget [(0,1),(1,0)] 1 = mappedTarget [(1,0),(0,1)] 1 ∧
    mappedTarget [(0,1),(1,0)] 2 = none ∧
    swap.forward 2 = 2 ∧ renameRef 0 swap.forward ⟨1,0⟩ = ⟨1,0⟩ := by decide

theorem train_guarded_source_exchange (junction : Track → Prop)
    (semaphore : Signal → Prop) (signals : Track → Signal → Prop) :
    (∀ s, semaphore s → ∀ t j, junction j →
      signals t s ∧ ¬ ∃ u, signals j u) ↔
    (∀ s, semaphore s → ∀ j t, junction j →
      signals t s ∧ ¬ ∃ u, signals j u) := by
  constructor <;> intro h s hs a b hj <;> exact h s hs b a hj

-- Comparison alpha-copies allocate new invocation targets but retain every
-- ordered edge and its ambient slot map. No seal is issued from a stale input.
structure Invocation where
  parent : Nat
  target : Nat
  slots : List (Nat × Nat)
  deriving DecidableEq

def cloneInvocations (allocate : Nat → Nat) (edges : List Invocation) :=
  edges.map fun e => { e with parent := allocate e.parent, target := allocate e.target }

def cloneSeal (allocate : Nat → Nat) (actual : List Invocation)
    (sealed : Option (List Invocation)) : Option (List Invocation) :=
  if sealed = some actual then some (cloneInvocations allocate actual) else none

theorem authenticated_copy_sealed (allocate : Nat → Nat) (actual : List Invocation) :
    cloneSeal allocate actual (some actual) = some (cloneInvocations allocate actual) := by
  simp [cloneSeal]

theorem stale_copy_not_sealed (allocate : Nat → Nat) (actual : List Invocation)
    (sealed : Option (List Invocation)) (stale : sealed ≠ some actual) :
    cloneSeal allocate actual sealed = none := by simp [cloneSeal, stale]

theorem copy_retains_ordered_slot_maps (allocate : Nat → Nat) (actual : List Invocation) :
    (cloneInvocations allocate actual).map Invocation.slots = actual.map Invocation.slots := by
  simp [cloneInvocations, List.map_map]

theorem copied_structural_group_sound
    (head : StructuralDeclarationTyping.Head) (original selected : StructuralDeclarationTyping.Group)
    (checked : StructuralDeclarationTyping.structuralAdmission head original selected = true)
    (domain : StructuralDeclarationTyping.Group → (StructuralDeclarationTyping.Slot → A) → A → Prop)
    (env : StructuralDeclarationTyping.Slot → A) :
    StructuralDeclarationTyping.permits domain env selected ↔
      StructuralDeclarationTyping.permits domain env original :=
  StructuralDeclarationTyping.admitted_group_sound head original selected checked domain env

def disjointCopySourceHash := "dff176fa00eded4109b5d08872b134a5b5ddeebea215acf3a64fcc6566e01d2c"
-- Positions are source-relative: DISJ domain User, then the two typed variables.
def disjointCopyEdges : List Invocation := [⟨0,1,[]⟩,⟨0,2,[]⟩,⟨0,3,[]⟩]
theorem old_copy_loses_seal : (none : Option (List Invocation)) ≠ some disjointCopyEdges := by decide
theorem disjoint_copy_accepted : cloneSeal (· + 4) disjointCopyEdges (some disjointCopyEdges) =
    some [⟨4,5,[]⟩,⟨4,6,[]⟩,⟨4,7,[]⟩] := by decide
theorem changed_invocation_not_resealed :
    cloneSeal (· + 4) [⟨0,1,[(0,1)]⟩,⟨0,2,[]⟩,⟨0,3,[]⟩]
      (some disjointCopyEdges) = none := by decide
theorem substituted_child_not_resealed :
    cloneSeal (· + 4) [⟨0,1,[]⟩,⟨0,9,[]⟩,⟨0,3,[]⟩]
      (some disjointCopyEdges) = none := by decide

end CrossReferenceSelection
