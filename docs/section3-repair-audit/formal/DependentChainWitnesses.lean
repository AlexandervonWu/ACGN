/- Bounded A2-07/A2-11 contracts. Keys are structures, never digest authority.
   The combination function is an explicit dependency, not an assumed theorem
   about arbitrary Java execution or authenticated parser hierarchies. -/
namespace ACGN.FourthFive.DependentChainWitnesses

inductive Key where
  | node : String -> List String -> List Key -> Key
  deriving Repr

mutual
  def keyDecEq : (a b : Key) -> Decidable (a = b)
    | .node t s cs, .node u r ds =>
      match decEq t u, decEq s r, keysDecEq cs ds with
      | isTrue h, isTrue j, isTrue k => isTrue (by cases h; cases j; cases k; rfl)
      | isFalse h, _, _ => isFalse (by intro eq; cases eq; exact h rfl)
      | _, isFalse h, _ => isFalse (by intro eq; cases eq; exact h rfl)
      | _, _, isFalse h => isFalse (by intro eq; cases eq; exact h rfl)
  def keysDecEq : (a b : List Key) -> Decidable (a = b)
    | [], [] => isTrue rfl
    | [], _ :: _ => isFalse (by intro h; cases h)
    | _ :: _, [] => isFalse (by intro h; cases h)
    | a :: as, b :: bs =>
      match keyDecEq a b, keysDecEq as bs with
      | isTrue h, isTrue j => isTrue (by cases h; cases j; rfl)
      | isFalse h, _ => isFalse (by intro eq; cases eq; exact h rfl)
      | _, isFalse h => isFalse (by intro eq; cases eq; exact h rfl)
end

instance : DecidableEq Key := keyDecEq

def branch (tag : String) (children : List Key) : Key := .node tag [] children

inductive Column where
  | int
  | sig : String -> Column
  deriving DecidableEq, Repr

def columnKey : Column -> Key
  | .int => .node "type/INT" [] []
  | .sig name => .node "type/CONSTRUCTOR" ["AlloySig:" ++ name] []

structure Family where
  arity : Nat
  products : List (List Column)
  deriving DecidableEq, Repr

def validFamily (f : Family) : Bool :=
  0 < f.arity && f.products.all (fun p => p.length == f.arity)

def familyKey (f : Family) : Key :=
  match f.products with
  | [] => .node "type/CONSTRUCTOR" ["AlloyEmptyRelation$arity=" ++ toString f.arity] []
  | [p] => branch "type/RELATION" (p.map columnKey)
  | ps => .node "type/CONSTRUCTOR" ["AlloyRelationUnion"]
      (ps.map (fun p => branch "type/RELATION" (p.map columnKey)))

inductive Stored where
  | relation : Family -> Stored
  | primitive : Column -> Stored
  | other : Key -> Stored
  deriving DecidableEq, Repr

inductive Rule where
  | exact
  | primitive
  deriving DecidableEq, Repr

def ruleName : Rule -> String
  | .exact => "EXACT_RELATION"
  | .primitive => "PRIMITIVE_SET_SINGLETON"

def derive (s : Stored) (view : Family) : Option Rule :=
  if !validFamily view then none else
  match s with
  | .relation f => if f = view then some .exact else none
  | .primitive c => if view = { arity := 1, products := [[c]] }
      then some .primitive else none
  | .other _ => none

def leafProof (rule : Rule) (stored view : Key) : Key :=
  .node "dependent-chain-leaf-type-proof-v1" [ruleName rule] [stored, view]

def storedKey : Stored -> Key
  | .relation f => familyKey f
  | .primitive .int => columnKey .int
  | .primitive (.sig name) => .node "type/CONSTRUCTOR" ["AlloyCarrier"] [columnKey (.sig name)]
  | .other k => k

def checkLeaf (s : Stored) (view : Family) (rule : Rule) (proof : Key) : Bool :=
  derive s view == some rule && proof == leafProof rule (storedKey s) (familyKey view)

theorem exact_derivation (s : Stored) (v : Family) :
    derive s v = some .exact <-> validFamily v = true /\ s = .relation v := by
  cases s <;> simp [derive] <;> split <;> simp_all

theorem primitive_derivation (s : Stored) (v : Family) :
    derive s v = some .primitive <->
      exists c, s = .primitive c /\ v = { arity := 1, products := [[c]] } := by
  cases s <;> simp [derive]
  intro h
  simp [h, validFamily]

theorem checked_leaf_exact_coordinates (s : Stored) (v : Family)
    (r : Rule) (p : Key) (h : checkLeaf s v r p = true) :
    derive s v = some r /\ p = leafProof r (storedKey s) (familyKey v) := by
  simpa [checkLeaf] using h

theorem proof_injective (r r' : Rule) (s v s' v' : Key) :
    leafProof r s v = leafProof r' s' v' <-> r = r' /\ s = s' /\ v = v' := by
  cases r <;> cases r' <;> simp [leafProof, ruleName]

theorem typed_empty_exact (n : Nat) (h : 0 < n) :
    derive (.relation { arity := n, products := [] }) { arity := n, products := [] }
      = some .exact := by simp [derive, validFamily, h]

theorem empty_not_primitive (n : Nat) (c : Column) :
    derive (.primitive c) { arity := n, products := [] } = none := by
  simp [derive]

theorem absent_not_univ (k : Key) :
    derive (.other k) { arity := 1, products := [[.sig "univ"]] } = none := by rfl

theorem explicit_univ :
    derive (.primitive (.sig "univ")) { arity := 1, products := [[.sig "univ"]] }
      = some .primitive := by decide

def leafKey (port proof dag : Key) : Key :=
  branch "dependent-chain-leaf-v4" [port, proof, dag]

def applicationKey (kind : String) (context output dag left right : Key)
    (cases : List Key) : Key :=
  .node "dependent-chain-application-v3" [kind]
    [context, output, dag, left, right, branch "dependent-chain-combination-cases-v1" cases]

def stepKey (index : Nat) (left right result : Key) (cases : List Key) : Key :=
  .node "dependent-chain-fold-step-v1" [toString index]
    [left, right, branch "dependent-chain-complete-case-matrix-v1" cases, result]

abbrev Combine := Key -> Key -> Option (Prod Key (List Key))

def foldSteps (combine : Combine) (index : Nat) (left : Key) :
    List Key -> Option (Prod Key (List Key))
  | [] => some (left, [])
  | right :: rest => do
    let (result, cases) <- combine left right
    let (final, steps) <- foldSteps combine (index + 1) result rest
    pure (final, stepKey index left right result cases :: steps)

def indexKey (version digest kind : String) (operands steps : List Key) (result : Key) : Key :=
  .node "dependent-chain-theory-index-v3" [version, digest, kind]
    [branch "dependent-chain-operand-dags-v1" operands,
     branch "dependent-chain-fold-steps-v1" steps, result]

def reconstruct (combine : Combine) (version digest kind : String)
    (operands : List Key) (result : Key) : Option Key :=
  match operands with
  | first :: second :: rest => do
      let (final, steps) <- foldSteps combine 1 first (second :: rest)
      if final = result then pure (indexKey version digest kind operands steps result) else none
  | _ => none

theorem fold_cons (combine : Combine) (i : Nat) (l r out final : Key)
    (cases steps rest : List Key) (h : combine l r = some (out, cases))
    (tail : foldSteps combine (i + 1) out rest = some (final, steps)) :
    foldSteps combine i l (r :: rest) =
      some (final, stepKey i l r out cases :: steps) := by simp [foldSteps, h, tail]

theorem complete_reconstruction (combine : Combine) (v d k : String)
    (a b result : Key) (rest steps : List Key)
    (h : foldSteps combine 1 a (b :: rest) = some (result, steps)) :
    reconstruct combine v d k (a :: b :: rest) result =
      some (indexKey v d k (a :: b :: rest) steps result) := by
  simp [reconstruct, h]

theorem reconstruction_requires_complete_fold (combine : Combine) (v d k : String)
    (a b result observed : Key) (rest : List Key)
    (h : reconstruct combine v d k (a :: b :: rest) result = some observed) :
    exists steps, foldSteps combine 1 a (b :: rest) = some (result, steps) /\
      observed = indexKey v d k (a :: b :: rest) steps result := by
  cases folded : foldSteps combine 1 a (b :: rest) with
  | none => simp [reconstruct, folded] at h
  | some pair =>
    rcases pair with ⟨final, steps⟩
    by_cases same : final = result
    · subst final
      simp [reconstruct, folded] at h
      exact ⟨steps, rfl, h.symm⟩
    · simp [reconstruct, folded, same] at h

theorem fold_step_count (combine : Combine) (i : Nat) (left final : Key)
    (rest steps : List Key) (h : foldSteps combine i left rest = some (final, steps)) :
    steps.length = rest.length := by
  induction rest generalizing i left final steps with
  | nil =>
    simp [foldSteps] at h
    exact h.2.symm ▸ rfl
  | cons right rest ih =>
    cases combined : combine left right with
    | none => simp [foldSteps, combined] at h
    | some pair =>
      rcases pair with ⟨out, cases⟩
      cases tail : foldSteps combine (i + 1) out rest with
      | none => simp [foldSteps, combined, tail] at h
      | some pair =>
        rcases pair with ⟨last, remaining⟩
        simp [foldSteps, combined, tail] at h
        rw [← h.2]
        simp [ih (i + 1) out last remaining tail]

theorem step_all_coordinates (i j : Nat) (l r out l' r' out' : Key)
    (cs cs' : List Key) :
    stepKey i l r out cs = stepKey j l' r' out' cs' <->
      toString i = toString j /\ l = l' /\ r = r' /\ cs = cs' /\ out = out' := by
  simp [stepKey, branch]

theorem wrong_result_rejected (combine : Combine) (v d k : String)
    (a b result wrong : Key) (rest steps : List Key)
    (h : foldSteps combine 1 a (b :: rest) = some (result, steps))
    (different : Not (result = wrong)) :
    reconstruct combine v d k (a :: b :: rest) wrong = none := by
  simp [reconstruct, h, different]

theorem index_all_coordinates (v d k v' d' k' : String)
    (ops steps ops' steps' : List Key) (result result' : Key) :
    indexKey v d k ops steps result = indexKey v' d' k' ops' steps' result' <->
      v = v' /\ d = d' /\ k = k' /\ ops = ops' /\ steps = steps' /\ result = result' := by
  simp [indexKey, branch, and_assoc]

-- Details are executable data. The theory digest is an explicit scalar, not a proof of injectivity.
def details (digest : String) (profile index source occurrence target : Key) : List Key :=
  [profile, .node "dependent-chain-theory" [digest] [], index, source, occurrence, target]

theorem details_all_coordinates (d d' : String) (p i s o t p' i' s' o' t' : Key) :
    details d p i s o t = details d' p' i' s' o' t' <->
      d = d' /\ p = p' /\ i = i' /\ s = s' /\ o = o' /\ t = t' := by
  simp [details, and_comm, and_left_comm]

theorem leaf_all_coordinates (p t d p' t' d' : Key) :
    leafKey p t d = leafKey p' t' d' <-> p = p' /\ t = t' /\ d = d' := by
  simp [leafKey, branch]

theorem source_association_coordinates (k k' : String)
    (c o d l r c' o' d' l' r' : Key) (cs cs' : List Key) :
    applicationKey k c o d l r cs = applicationKey k' c' o' d' l' r' cs' <->
      k = k' /\ c = c' /\ o = o' /\ d = d' /\ l = l' /\ r = r' /\ cs = cs' := by
  simp [applicationKey, branch]

-- Products also name an implicit exact relation type, including case products
-- later pruned from a normalized DAG. Merely scanning explicit type nodes misses it.
def productColumns : List Key -> Option (List Key)
  | [] => some []
  | .node "dependent-column-evidence-v1" [] [column, _] :: rest =>
      (productColumns rest).map (column :: ·)
  | _ => none

def localTypes (tag : String) (scalars : List String) (children : List Key) : List Key :=
  if tag ∈ ["type/TYPE_VARIABLE", "type/INT", "type/BOOL", "type/ARROW", "type/RELATION", "type/CONSTRUCTOR"]
    then [.node tag scalars children]
  else if tag = "dependent-type-product-v1" ∨ tag = "dependent-type-case-result-v1" then
    match productColumns children with
    | some columns => [branch "type/RELATION" columns]
    | none => []
  else []

mutual
  def requiredTypes : Key -> List Key
    | .node tag scalars children => localTypes tag scalars children ++ requiredTypesList children
  def requiredTypesList : List Key -> List Key
    | [] => []
    | k :: ks => requiredTypes k ++ requiredTypesList ks
end

def publishes (ledger : List Key) (k : Key) : Bool :=
  (requiredTypes k).all (fun t => decide (t ∈ ledger))

def register (ledger : List Key) (k : Key) : List Key := ledger ++ requiredTypes k

theorem publishes_iff (ledger : List Key) (k : Key) :
    publishes ledger k = true <-> ∀ t ∈ requiredTypes k, t ∈ ledger := by
  simp [publishes]

theorem register_coverage (ledger : List Key) (k : Key) :
    publishes (register ledger k) k = true := by
  rw [publishes_iff]
  intro t ht
  exact List.mem_append_right _ ht

theorem required_list_member (ks : List Key) (k t : Key)
    (hk : k ∈ ks) (ht : t ∈ requiredTypes k) : t ∈ requiredTypesList ks := by
  induction ks with
  | nil => simp at hk
  | cons head tail ih =>
    simp only [List.mem_cons] at hk
    rcases hk with same | rest
    · subst head; exact List.mem_append_left _ ht
    · exact List.mem_append_right _ (ih rest)

theorem index_registry_coverage (ledger operands steps : List Key) (v d k : String)
    (result : Key) (h : publishes ledger (indexKey v d k operands steps result) = true) :
    (∀ step ∈ steps, publishes ledger step = true) ∧ publishes ledger result = true := by
  rw [publishes_iff] at h
  have localIndex : ∀ ss cs, localTypes "dependent-chain-theory-index-v3" ss cs = [] := by
    intro ss cs; simp [localTypes]
  have localOperands : ∀ cs, localTypes "dependent-chain-operand-dags-v1" [] cs = [] := by
    intro cs; simp [localTypes]
  have localSteps : ∀ cs, localTypes "dependent-chain-fold-steps-v1" [] cs = [] := by
    intro cs; simp [localTypes]
  simp only [indexKey, branch, requiredTypes, requiredTypesList, localIndex, localOperands, localSteps] at h
  simp only [List.nil_append, List.append_nil, List.mem_append] at h
  constructor
  · intro step member
    rw [publishes_iff]
    intro t ht
    apply h
    exact Or.inr (Or.inl (required_list_member steps step t member ht))
  · rw [publishes_iff]
    intro t ht
    apply h
    exact Or.inr (Or.inr ht)

theorem step_registry_result (ledger cases : List Key) (i : Nat) (l r result : Key)
    (h : publishes ledger (stepKey i l r result cases) = true) :
    publishes ledger result = true := by
  rw [publishes_iff] at h ⊢
  intro t ht
  apply h
  simp [stepKey, branch, requiredTypes, requiredTypesList, localTypes, ht]

theorem reconstructed_registry_fold_coverage (combine : Combine) (v d k : String)
    (a b result observed : Key) (rest ledger : List Key)
    (replayed : reconstruct combine v d k (a :: b :: rest) result = some observed)
    (published : publishes ledger observed = true) :
    ∃ steps, foldSteps combine 1 a (b :: rest) = some (result, steps) ∧
      ∀ i l r out cases, stepKey i l r out cases ∈ steps -> publishes ledger out = true := by
  obtain ⟨steps, folded, exactIndex⟩ :=
    reconstruction_requires_complete_fold combine v d k a b result observed rest replayed
  refine ⟨steps, folded, ?_⟩
  intro i l r out cases member
  rw [exactIndex] at published
  exact step_registry_result ledger cases i l r out
    ((index_registry_coverage ledger (a :: b :: rest) steps v d k result published).1 _ member)

theorem missing_required_type_rejected (ledger : List Key) (k t : Key)
    (required : t ∈ requiredTypes k) (absent : t ∉ ledger) : publishes ledger k = false := by
  cases h : publishes ledger k with
  | false => rfl
  | true => exact False.elim (absent ((publishes_iff ledger k).mp h t required))

theorem published_child (ledger children : List Key) (tag : String) (scalars : List String)
    (child : Key) (h : publishes ledger (.node tag scalars children) = true)
    (member : child ∈ children) : publishes ledger child = true := by
  rw [publishes_iff] at h ⊢
  intro t ht
  exact h t (List.mem_append_right _ (required_list_member children child t member ht))

theorem step_registry_case (ledger cases : List Key) (i : Nat) (l r result proof : Key)
    (h : publishes ledger (stepKey i l r result cases) = true) (member : proof ∈ cases) :
    publishes ledger proof = true := by
  have matrix := published_child ledger _ _ _ (branch "dependent-chain-complete-case-matrix-v1" cases)
    h (by simp)
  exact published_child ledger cases _ [] proof matrix member

theorem product_registry_exact_relation (ledger evidence columns : List Key) (tag : String)
    (tagged : tag = "dependent-type-product-v1" ∨ tag = "dependent-type-case-result-v1")
    (shape : productColumns evidence = some columns)
    (h : publishes ledger (.node tag [] evidence) = true) :
    branch "type/RELATION" columns ∈ ledger := by
  rw [publishes_iff] at h
  apply h
  rcases tagged with rfl | rfl <;> simp [requiredTypes, localTypes, shape]

#print axioms exact_derivation
#print axioms primitive_derivation
#print axioms checked_leaf_exact_coordinates
#print axioms proof_injective
#print axioms typed_empty_exact
#print axioms empty_not_primitive
#print axioms absent_not_univ
#print axioms explicit_univ
#print axioms fold_cons
#print axioms complete_reconstruction
#print axioms reconstruction_requires_complete_fold
#print axioms fold_step_count
#print axioms step_all_coordinates
#print axioms wrong_result_rejected
#print axioms index_all_coordinates
#print axioms details_all_coordinates
#print axioms leaf_all_coordinates
#print axioms source_association_coordinates
#print axioms publishes_iff
#print axioms register_coverage
#print axioms required_list_member
#print axioms index_registry_coverage
#print axioms step_registry_result
#print axioms reconstructed_registry_fold_coverage
#print axioms missing_required_type_rejected
#print axioms published_child
#print axioms step_registry_case
#print axioms product_registry_exact_relation
end ACGN.FourthFive.DependentChainWitnesses
