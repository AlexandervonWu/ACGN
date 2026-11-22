import Std

/-!
Slot 9 (`AMBIGUOUS_OCCURRENCE_BIJECTION`), part 1 of 2: labelled endpoint
trees, occurrence reads, deep twin comparison, twin exchanges and ordered
selected actions.

Model. An endpoint is a finite labelled tree. An occurrence is a child-index
path, so two uses of a shared node object, and two distinct equal objects, are
different occurrences. A label carries every node-local observation of the
certified endpoint: `head` (operator, payload, exact type, binder coordinate),
the order flag, `origin` (authenticated source-occurrence provenance, 0 when a
node carries none), `owner` (declaration owner association) and `phase`.

Proved here, under the premises stated in each theorem:
* `twin` is a decidable deep comparison that implies equality of labelled trees;
* exchanging two twin siblings is an involutive, injective and surjective map
  of occurrences that preserves the subtree read at every occurrence, and so
  does any finite composition of such exchanges;
* an ordered action list transported along such compositions on the left
  (source) and right (target) endpoints keeps its order, kinds, charges and
  every resolved source and target subtree;
* when no action coordinate lies at or below an exchanged twin, the transported
  list is literally the same list.

Explicit modelling premise: `resolve` is what a replay can observe of an action
(kind, charge, source subtree of the left endpoint, target subtree of the right
endpoint). That Java consumers observe nothing else is a Java obligation.
-/
namespace ACGN.FifthFive.RepeatedOccurrence

structure Label where
  head : String
  unordered : Bool
  origin : Nat
  owner : Nat
  phase : Nat
  deriving DecidableEq

inductive Tree where
  | node (label : Label) (children : List Tree)

abbrev Path := List Nat

def children : Tree → List Tree
  | .node _ cs => cs

def get? : Path → Tree → Option Tree
  | [], t => some t
  | i :: rest, t =>
    match (children t)[i]? with
    | none => none
    | some c => get? rest c

/-! ### Decidable twin comparison (the deep check performed on candidates) -/

mutual
def twin : Tree → Tree → Bool
  | .node l cs, .node l' cs' => decide (l = l') && twinList cs cs'
def twinList : List Tree → List Tree → Bool
  | [], [] => true
  | a :: as, b :: bs => twin a b && twinList as bs
  | [], _ :: _ => false
  | _ :: _, [] => false
end

mutual
theorem twin_sound : ∀ (a b : Tree), twin a b = true → a = b
  | .node l cs, .node l' cs', h => by
    simp only [twin, Bool.and_eq_true, decide_eq_true_eq] at h
    obtain ⟨hl, hc⟩ := h
    rw [hl, twinList_sound cs cs' hc]
theorem twinList_sound : ∀ (as bs : List Tree), twinList as bs = true → as = bs
  | [], [], _ => rfl
  | a :: as, b :: bs, h => by
    simp only [twinList, Bool.and_eq_true] at h
    rw [twin_sound a b h.1, twinList_sound as bs h.2]
  | [], _ :: _, h => by simp [twinList] at h
  | _ :: _, [], h => by simp [twinList] at h
end

mutual
theorem twin_refl : ∀ (a : Tree), twin a a = true
  | .node l cs => by simp [twin, twinList_refl cs]
theorem twinList_refl : ∀ (as : List Tree), twinList as as = true
  | [] => rfl
  | a :: as => by simp [twinList, twin_refl a, twinList_refl as]
end

theorem twin_iff (a b : Tree) : twin a b = true ↔ a = b :=
  ⟨twin_sound a b, fun h => h ▸ twin_refl a⟩

/-! ### Occurrence reads -/

theorem get_child (i : Nat) (t : Tree) : get? [i] t = (children t)[i]? := by
  simp only [get?]
  cases (children t)[i]? <;> rfl

theorem get_append : ∀ (p q : Path) (t : Tree),
    get? (p ++ q) t = (get? p t).bind (get? q)
  | [], _, _ => rfl
  | i :: p, q, t => by
    simp only [List.cons_append, get?]
    cases (children t)[i]? with
    | none => rfl
    | some c => exact get_append p q c

/-! ### Twin exchanges -/

def swapIdx (j k i : Nat) : Nat := if i = j then k else if i = k then j else i

/-- Exchange the occurrences below children `j` and `k` of the node at `p`. -/
def swapAt : Path → Nat → Nat → Path → Path
  | [], j, k, i :: rest => swapIdx j k i :: rest
  | [], _, _, [] => []
  | _ :: _, _, _, [] => []
  | a :: p, j, k, b :: q => if a = b then b :: swapAt p j k q else b :: q

theorem swapIdx_invol (j k i : Nat) : swapIdx j k (swapIdx j k i) = i := by
  unfold swapIdx
  repeat' split
  all_goals omega

theorem swapAt_invol : ∀ (p : Path) (j k : Nat) (q : Path),
    swapAt p j k (swapAt p j k q) = q
  | [], _, _, [] => rfl
  | [], j, k, i :: rest => by simp [swapAt, swapIdx_invol]
  | _ :: _, _, _, [] => rfl
  | a :: p, j, k, b :: q => by
    by_cases h : a = b
    · simp [swapAt, h, swapAt_invol p j k q]
    · simp [swapAt, h]

/-- Injectivity: distinct occurrences stay distinct (multiplicity is kept). -/
theorem swapAt_injective (p : Path) (j k : Nat) (q q' : Path)
    (h : swapAt p j k q = swapAt p j k q') : q = q' := by
  have := congrArg (swapAt p j k) h
  rwa [swapAt_invol, swapAt_invol] at this

/-- Coverage: every occurrence is the image of an occurrence. -/
theorem swapAt_surjective (p : Path) (j k : Nat) (q : Path) :
    ∃ q', swapAt p j k q' = q := ⟨swapAt p j k q, swapAt_invol p j k q⟩

/-- Twin siblings: the exchange preserves the subtree read at every occurrence.
The premise is equality of the two labelled subtrees actually present. -/
theorem get_swap : ∀ (p : Path) (j k : Nat) (t a : Tree) (q : Path),
    get? (p ++ [j]) t = some a → get? (p ++ [k]) t = some a →
    get? (swapAt p j k q) t = get? q t
  | [], _, _, _, _, [], _, _ => rfl
  | [], j, k, t, a, i :: rest, hj, hk => by
    have hj' : (children t)[j]? = some a := by rw [← get_child]; exact hj
    have hk' : (children t)[k]? = some a := by rw [← get_child]; exact hk
    simp only [swapAt, swapIdx]
    by_cases h1 : i = j
    · subst h1; simp [get?, hj', hk']
    · by_cases h2 : i = k
      · subst h2; simp [get?, hj', hk', h1]
      · simp [h1, h2]
  | _ :: _, _, _, _, _, [], _, _ => rfl
  | x :: p, j, k, t, a, b :: q, hj, hk => by
    by_cases h : x = b
    · subst h
      simp only [swapAt, ite_true, get?]
      simp only [List.cons_append, get?] at hj hk
      cases hc : (children t)[x]? with
      | none => rfl
      | some c =>
        rw [hc] at hj hk
        exact get_swap p j k c a q hj hk
    · simp [swapAt, h]

def isPrefix : Path → Path → Bool
  | [], _ => true
  | _ :: _, [] => false
  | a :: p, b :: q => a == b && isPrefix p q

/-- An occurrence that is not at or below either twin is fixed. -/
theorem swapAt_fixed : ∀ (p : Path) (j k : Nat) (q : Path),
    isPrefix (p ++ [j]) q = false → isPrefix (p ++ [k]) q = false →
    swapAt p j k q = q
  | [], _, _, [], _, _ => rfl
  | [], j, k, i :: rest, hj, hk => by
    simp [isPrefix] at hj hk
    have h1 : ¬ i = j := fun h => hj h.symm
    have h2 : ¬ i = k := fun h => hk h.symm
    simp [swapAt, swapIdx, h1, h2]
  | _ :: _, _, _, [], _, _ => rfl
  | a :: p, j, k, b :: q, hj, hk => by
    by_cases h : a = b
    · subst h
      simp [isPrefix] at hj hk
      simp [swapAt, swapAt_fixed p j k q hj hk]
    · simp [swapAt, h]

/-! ### Compositions of twin exchanges -/

structure Exchange where
  parent : Path
  j : Nat
  k : Nat

def swapAll : List Exchange → Path → Path
  | [], q => q
  | e :: es, q => swapAt e.parent e.j e.k (swapAll es q)

/-- The exchange is between two equal labelled subtrees actually present. -/
def TwinExchange (t : Tree) (e : Exchange) : Prop :=
  ∃ a, get? (e.parent ++ [e.j]) t = some a ∧ get? (e.parent ++ [e.k]) t = some a

/-- Any composition of twin exchanges preserves every occurrence read. The
endpoint is immutable, so each exchange is judged against the same tree. -/
theorem get_swapAll (t : Tree) : ∀ (es : List Exchange), (∀ e ∈ es, TwinExchange t e) →
    ∀ q, get? (swapAll es q) t = get? q t
  | [], _, _ => rfl
  | e :: es, h, q => by
    obtain ⟨a, hj, hk⟩ := h e (List.mem_cons_self ..)
    show get? (swapAt e.parent e.j e.k (swapAll es q)) t = get? q t
    rw [get_swap e.parent e.j e.k t a (swapAll es q) hj hk]
    exact get_swapAll t es (fun e' he' => h e' (List.mem_cons_of_mem _ he')) q

theorem swapAll_injective : ∀ (es : List Exchange) (q q' : Path),
    swapAll es q = swapAll es q' → q = q'
  | [], _, _, h => h
  | e :: es, q, q', h =>
    swapAll_injective es q q' (swapAt_injective e.parent e.j e.k _ _ h)

theorem swapAll_surjective : ∀ (es : List Exchange) (q : Path), ∃ q', swapAll es q' = q
  | [], q => ⟨q, rfl⟩
  | e :: es, q => by
    obtain ⟨q', hq'⟩ := swapAll_surjective es (swapAt e.parent e.j e.k q)
    refine ⟨q', ?_⟩
    show swapAt e.parent e.j e.k (swapAll es q') = q
    rw [hq', swapAt_invol]

def pathClear (e : Exchange) (q : Path) : Bool :=
  !isPrefix (e.parent ++ [e.j]) q && !isPrefix (e.parent ++ [e.k]) q

theorem swapAll_fixed : ∀ (es : List Exchange) (q : Path),
    (∀ e ∈ es, pathClear e q = true) → swapAll es q = q
  | [], _, _ => rfl
  | e :: es, q, h => by
    have he := h e (List.mem_cons_self ..)
    simp [pathClear] at he
    show swapAt e.parent e.j e.k (swapAll es q) = q
    rw [swapAll_fixed es q (fun e' he' => h e' (List.mem_cons_of_mem _ he'))]
    exact swapAt_fixed e.parent e.j e.k q he.1 he.2

/-! ### Ordered selected actions -/

structure Action where
  kind : String
  cost : Nat
  source : Option Path
  target : Option Path
  deriving DecidableEq

/-- What a replay can observe of an action: kind, charge and the source
subtree of the left endpoint and target subtree of the right endpoint. -/
structure Resolved where
  kind : String
  cost : Nat
  source : Option (Option Tree)
  target : Option (Option Tree)

def resolve (left right : Tree) (a : Action) : Resolved :=
  ⟨a.kind, a.cost, a.source.map (fun q => get? q left), a.target.map (fun q => get? q right)⟩

/-- Re-coordinate the source through `f` (left endpoint) and the target
through `g` (right endpoint). Order, kind and charge are untouched. -/
def mapBoth (f g : Path → Path) (a : Action) : Action :=
  { a with source := a.source.map f, target := a.target.map g }

def charge (as : List Action) : Nat := (as.map Action.cost).sum

theorem mapBoth_id (a : Action) : mapBoth id id a = a := by
  cases a with
  | mk kind cost source target =>
    cases source <;> cases target <;> rfl

theorem map_mapBoth_id (as : List Action) : as.map (mapBoth id id) = as := by
  induction as with
  | nil => rfl
  | cons a rest ih => simp only [List.map_cons, mapBoth_id, ih]

theorem charge_mapBoth (f g : Path → Path) (as : List Action) :
    charge (as.map (mapBoth f g)) = charge as := by
  induction as with
  | nil => rfl
  | cons a rest ih => simp_all [charge, mapBoth]

/-- Coordinate maps that agree at an action's own coordinates give the same action. -/
theorem mapBoth_congr (f f' g g' : Path → Path) (a : Action)
    (hs : ∀ q, a.source = some q → f q = f' q)
    (ht : ∀ q, a.target = some q → g q = g' q) :
    mapBoth f g a = mapBoth f' g' a := by
  cases a with
  | mk kind cost source target =>
    cases source with
    | none =>
      cases target with
      | none => rfl
      | some t => simp [mapBoth, ht t rfl]
    | some s =>
      cases target with
      | none => simp [mapBoth, hs s rfl]
      | some t => simp [mapBoth, hs s rfl, ht t rfl]

theorem mapBoth_list_congr (f f' g g' : Path → Path) (as : List Action)
    (hs : ∀ a ∈ as, ∀ q, a.source = some q → f q = f' q)
    (ht : ∀ a ∈ as, ∀ q, a.target = some q → g q = g' q) :
    as.map (mapBoth f g) = as.map (mapBoth f' g') := by
  induction as with
  | nil => rfl
  | cons a rest ih =>
    simp only [List.map_cons]
    rw [mapBoth_congr f f' g g' a (hs a (List.mem_cons_self ..)) (ht a (List.mem_cons_self ..)),
      ih (fun b hb => hs b (List.mem_cons_of_mem _ hb))
        (fun b hb => ht b (List.mem_cons_of_mem _ hb))]

/-- Coordinate maps that read the same subtrees at an action's own coordinates
resolve it identically. -/
theorem resolve_congr (left right : Tree) (f f' g g' : Path → Path) (a : Action)
    (hs : ∀ q, a.source = some q → get? (f q) left = get? (f' q) left)
    (ht : ∀ q, a.target = some q → get? (g q) right = get? (g' q) right) :
    resolve left right (mapBoth f g a) = resolve left right (mapBoth f' g' a) := by
  cases a with
  | mk kind cost source target =>
    cases source with
    | none =>
      cases target with
      | none => rfl
      | some t => simp [resolve, mapBoth, ht t rfl]
    | some s =>
      cases target with
      | none => simp [resolve, mapBoth, hs s rfl]
      | some t => simp [resolve, mapBoth, hs s rfl, ht t rfl]

theorem resolve_list_congr (left right : Tree) (f f' g g' : Path → Path) (as : List Action)
    (hs : ∀ a ∈ as, ∀ q, a.source = some q → get? (f q) left = get? (f' q) left)
    (ht : ∀ a ∈ as, ∀ q, a.target = some q → get? (g q) right = get? (g' q) right) :
    (as.map (mapBoth f g)).map (resolve left right) =
      (as.map (mapBoth f' g')).map (resolve left right) := by
  induction as with
  | nil => rfl
  | cons a rest ih =>
    simp only [List.map_cons]
    rw [resolve_congr left right f f' g g' a (hs a (List.mem_cons_self ..))
        (ht a (List.mem_cons_self ..)),
      ih (fun b hb => hs b (List.mem_cons_of_mem _ hb))
        (fun b hb => ht b (List.mem_cons_of_mem _ hb))]

/-! ### Transport of ordered actions along twin exchanges, both endpoints -/

/-- Transport keeps the list length, order, kinds, charges and resolved
content, for any composition of twin exchanges on the left endpoint (sources)
and on the right endpoint (targets). -/
theorem actions_exchange_transport (left right : Tree) (esL esR : List Exchange)
    (hL : ∀ e ∈ esL, TwinExchange left e) (hR : ∀ e ∈ esR, TwinExchange right e)
    (as : List Action) :
    (as.map (mapBoth (swapAll esL) (swapAll esR))).map (resolve left right) =
      as.map (resolve left right) := by
  have h := resolve_list_congr left right (swapAll esL) id (swapAll esR) id as
    (fun _ _ q _ => get_swapAll left esL hL q) (fun _ _ q _ => get_swapAll right esR hR q)
  rw [h, map_mapBoth_id]

/-- MATCHED under any composition of twin exchanges is a resolved
correspondence: if the bridged list agrees with the certified list after the
exchanges, the two lists resolve, in order, to the same kinds, charges and
subtrees on both endpoints. -/
theorem matched_exchange_choice (left right : Tree) (esL esR : List Exchange)
    (hL : ∀ e ∈ esL, TwinExchange left e) (hR : ∀ e ∈ esR, TwinExchange right e)
    (bridged certified : List Action)
    (h : bridged.map (mapBoth (swapAll esL) (swapAll esR)) = certified) :
    bridged.map (resolve left right) = certified.map (resolve left right) := by
  rw [← h, actions_exchange_transport left right esL esR hL hR]

/-- No source coordinate lies at or below a twin exchanged on the left
endpoint, and no target coordinate at or below one exchanged on the right. -/
def actionClear (esL esR : List Exchange) (a : Action) : Bool :=
  (match a.source with
    | none => true
    | some q => esL.all fun e => pathClear e q) &&
  (match a.target with
    | none => true
    | some q => esR.all fun e => pathClear e q)

theorem mapBoth_clear (esL esR : List Exchange) (a : Action)
    (h : actionClear esL esR a = true) : mapBoth (swapAll esL) (swapAll esR) a = a := by
  have hs : ∀ q, a.source = some q → swapAll esL q = id q := by
    intro q hq
    simp only [actionClear, hq, Bool.and_eq_true] at h
    exact swapAll_fixed esL q (fun e he => List.all_eq_true.mp h.1 e he)
  have ht : ∀ q, a.target = some q → swapAll esR q = id q := by
    intro q hq
    simp only [actionClear, hq, Bool.and_eq_true] at h
    exact swapAll_fixed esR q (fun e he => List.all_eq_true.mp h.2 e he)
  rw [mapBoth_congr (swapAll esL) id (swapAll esR) id a hs ht, mapBoth_id]

/-- Verdict independence for exchanges: when no bridged action coordinate lies
at or below an exchanged twin on its endpoint, the ordered comparison is the
same before and after any composition of exchanges. -/
theorem verdict_exchange_independent (esL esR : List Exchange)
    (bridged certified : List Action)
    (h : ∀ a ∈ bridged, actionClear esL esR a = true) :
    (bridged.map (mapBoth (swapAll esL) (swapAll esR)) = certified) ↔
      (bridged = certified) := by
  have : bridged.map (mapBoth (swapAll esL) (swapAll esR)) = bridged := by
    induction bridged with
    | nil => rfl
    | cons a rest ih =>
      simp only [List.map_cons]
      rw [mapBoth_clear esL esR a (h a (List.mem_cons_self ..)),
        ih (fun b hb => h b (List.mem_cons_of_mem _ hb))]
  rw [this]

end ACGN.FifthFive.RepeatedOccurrence
