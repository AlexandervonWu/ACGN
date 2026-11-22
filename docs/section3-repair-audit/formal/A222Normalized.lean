import A222Program
import A221Normalization

namespace A222.Normalized
open A222 ACGN.Ninth.A221

def project (code : AtomKey → Nat) (c : Column) : Col :=
  ⟨code c.atom,c.parents.map code,c.moduleId⟩
def rowOf (code : AtomKey → Nat) (p : Product) : Row := p.map (project code)
def rank (f : Forest) (code : AtomKey → Nat) (p : Product) :=
  (p.map fun c => (f.path (code c.atom)).length).sum

theorem group_property (P : Column → Prop) (raw : List Product)
    (valid : ∀ p ∈ raw, ∀ c ∈ p, P c) (p : Product) (hp : p ∈ groups raw) :
    ∀ c ∈ p, P c := by
  have hm : ∀ (a b : Product), (∀ x ∈ a, P x) → (∀ x ∈ b, P x) → ∀ x ∈ merge a b, P x := by
    intro a
    induction a with
    | nil => simp [merge]
    | cons a as ih =>
      intro b
      cases b with
      | nil => simp [merge]
      | cons b bs =>
        intro ha hb x hx
        rcases List.mem_cons.mp hx with eq | rest
        · subst x
          rcases pick_origin a b with h|h
          · rw [h]; exact ha a (by simp)
          · rw [h]; exact hb b (by simp)
        · exact ih bs (fun c hc => ha c (List.mem_cons_of_mem _ hc))
              (fun c hc => hb c (List.mem_cons_of_mem _ hc)) x rest
  have fold : ∀ (rs : List Product) (s : Option Product),
      (∀ z ∈ rs, ∀ c ∈ z, P c) → (∀ z, s = some z → ∀ c ∈ z, P c) →
      ∀ z, rs.foldl (update (key p)) s = some z → ∀ c ∈ z, P c := by
    intro rs
    induction rs with
    | nil => intro s _ h; exact h
    | cons r rs ih =>
      intro s h v
      apply ih (update (key p) s r) (fun z hz => h z (List.mem_cons_of_mem _ hz))
      intro z hz
      have hr := h r (by simp)
      by_cases hit : key r = key p
      · cases s with
        | none => simp [update,hit] at hz; simpa [←hz] using hr
        | some old => simp [update,hit] at hz; exact hz ▸ hm old r (v old rfl) hr
      · exact v z (by simpa [update,hit] using hz)
  exact fold raw none valid (by simp) p ((exact_group raw).1 hp)

theorem same_key (f : Forest) (code : AtomKey → Nat) {a b : Product} (h : key a = key b) (ws : List Nat) :
    inhabits f (rowOf code a) ws ↔ inhabits f (rowOf code b) ws := by
  induction a generalizing b ws with
  | nil => cases b <;> simp_all [key,rowOf]
  | cons a as ih =>
    cases b with
    | nil => simp [key] at h
    | cons b bs =>
      obtain ⟨head,tail⟩ := List.cons.inj h
      cases ws with
      | nil => rfl
      | cons w ws =>
        change (_ ∧ inhabits f (rowOf code as) ws) ↔ (_ ∧ inhabits f (rowOf code bs) ws)
        rw [ih tail]
        simp [project,head]

theorem grouped_denotation (f : Forest) (code : AtomKey → Nat) (raw : List Product) (ws : List Nat) :
    (∃ p ∈ groups raw, inhabits f (rowOf code p) ws) ↔ ∃ p ∈ raw, inhabits f (rowOf code p) ws := by
  constructor
  · rintro ⟨p,hp,den⟩
    have rep := (exact_group raw).1 hp
    obtain ⟨q,hq,k⟩ := (representative_present raw (key p)).1 (by rw [rep]; rfl)
    exact ⟨q,hq,(same_key f code k ws).2 den⟩
  · rintro ⟨p,hp,den⟩
    have pres := (representative_present raw (key p)).2 ⟨p,hp,rfl⟩
    cases eq : representative (key p) raw with
    | none => simp [eq] at pres
    | some q =>
      have k := fold_key (key p) raw (s:=none) (by simp) q eq
      exact ⟨q,(exact_group raw).2 (by simpa [k] using eq),(same_key f code k ws).2 den⟩

theorem coordinate_below (f : Forest) (code : AtomKey → Nat) (a b : Column)
    (good : fits f (project code a)) (h : weak a b) : below f (code a.atom) (code b.atom) := by
  rcases h with eq | ⟨owner,ha,_,anc⟩
  · rw [eq]; exact ⟨[],rfl⟩
  · have p : a.parents.map code = f.parents (code a.atom) := good (by simp [project,ha])
    exact member_suffix f _ _ (List.mem_cons_of_mem _ (p ▸ List.mem_map_of_mem anc))

theorem order_properties (f : Forest) (code : AtomKey → Nat) (inj : ∀ {a b}, code a = code b → a = b)
    (p q : Product) (good : ∀ c ∈ p, fits f (project code c)) (h : Weak weak p q) :
    rank f code q ≤ rank f code p ∧
    (rank f code q = rank f code p → key q = key p) ∧
    ∀ ws, inhabits f (rowOf code p) ws → inhabits f (rowOf code q) ws := by
  induction p generalizing q with
  | nil => cases q <;> simp_all [Weak,rank,key,rowOf]
  | cons a as ih =>
    cases q with
    | nil => simp [Weak] at h
    | cons b bs =>
      obtain ⟨head,tail⟩ := h
      have hb := coordinate_below f code a b (good a (by simp)) head
      obtain ⟨tle,teq,sound⟩ := ih bs (fun c hc => good c (List.mem_cons_of_mem _ hc)) tail
      have hle := hb.length_le
      change _ + rank f code bs ≤ _ + rank f code as ∧
        (_ + rank f code bs = _ + rank f code as → _ = _) ∧ _
      refine ⟨Nat.add_le_add hle tle,?_,?_⟩
      · intro sum
        change (f.path (code b.atom)).length + rank f code bs = (f.path (code a.atom)).length + rank f code as at sum
        have heq : (f.path (code b.atom)).length = (f.path (code a.atom)).length := by omega
        have keq : b.atom = a.atom := inj (List.cons.inj (hb.eq_of_length heq)).1
        have tails := teq (by omega)
        change b.atom :: key bs = a.atom :: key as
        rw [keq,tails]
      · intro ws
        cases ws with
        | nil => simp [rowOf,inhabits]
        | cons w ws =>
          intro ⟨ha,ht⟩
          exact ⟨hb.trans ha,sound ws ht⟩

theorem normalized_denotation (f : Forest) (code : AtomKey → Nat) (inj : ∀ {a b}, code a = code b → a = b)
    (raw : List Product) (good : ∀ p ∈ raw, ∀ c ∈ p, fits f (project code c)) (ws : List Nat) :
    familyContains f ((normalize raw).map (rowOf code)) ws ↔ familyContains f (raw.map (rowOf code)) ws := by
  have order := fun p (hp : p ∈ groups raw) q (h : Weak weak p q) =>
      order_properties f code inj p q (group_property _ raw good p hp) h
  have maxed := maximal_preserves_denotation (rows := groups raw) strict (rank f code)
      (fun p w => inhabits f (rowOf code p) w)
      (by intro p hp q _ h; obtain ⟨le,eq,_⟩ := order p hp q h.1
          exact Nat.lt_of_le_of_ne le (fun he => h.2 (eq he).symm))
      (by intro p hp q _ h; exact (order p hp q h.1).2.2) ws
  have result := maxed.trans (grouped_denotation f code raw ws)
  simp [familyContains,normalize]
  grind


theorem product_fit (f : Forest) (l r : Row) (a : Row)
    (fl : allFit f l) (fr : allFit f r) (result : product l r = .keep a) : allFit f a := by
  induction l generalizing r a with
  | nil => cases r <;> simp_all [product,allFit]
  | cons h hs ih =>
    cases r with
    | nil => simp [product] at result
    | cons k ks =>
      cases hc : chosen h k (classify h k) with
      | none => cases hb : classify h k <;> simp_all [product,chosen]
      | some c =>
        have origin : c = h ∨ c = k := by
          cases hb : classify h k <;> simp_all [chosen]
          split at hc <;> simp_all
        cases tail : product hs ks with
        | unsupported | dropped => simp [product,hc,tail,prepend] at result
        | keep rest =>
          simp [product,hc,tail,prepend] at result
          subst a
          have ready := ih ks rest (fun x hx => fl x (List.mem_cons_of_mem _ hx))
              (fun x hx => fr x (List.mem_cons_of_mem _ hx)) tail
          intro x hx
          rcases List.mem_cons.mp hx with eq|mem
          · subst x; rcases origin with hh|hk
            · exact hh ▸ fl h (by simp)
            · exact hk ▸ fr k (by simp)
          · exact ready x mem

theorem gathered_fit (f : Forest) (ps : List (Row × Row)) (a : List Row)
    (good : ∀ p ∈ ps, allFit f p.1 ∧ allFit f p.2) (done_ : gather ps = some a) :
    ∀ p ∈ a, allFit f p := by
  induction ps generalizing a with
  | nil => simp [gather] at done_; subst a; simp
  | cons pair tail ih =>
    obtain ⟨l,r⟩ := pair
    have both := good (l,r) (by simp)
    have rest := fun a => ih a (fun p hp => good p (List.mem_cons_of_mem _ hp))
    cases hp : product l r with
    | unsupported => simp [gather,hp] at done_
    | dropped => exact rest a (by simpa [gather,hp] using done_)
    | keep row =>
      cases ht : gather tail with
      | none => simp [gather,hp,ht] at done_
      | some rows =>
        simp [gather,hp,ht] at done_
        subst a
        intro p h
        rcases List.mem_cons.mp h with eq|mem
        · exact eq ▸ product_fit f l r row both.1 both.2 hp
        · exact rest rows ht p mem

/-- A binary producer step is represented by its actual row-pair collection, followed by
the A2-21 duplicate, absorption and sorting algorithm. Carrier codes preserve structural identity. -/
theorem normalized_intersection (f : Forest) (code : AtomKey → Nat) (inj : ∀ {a b}, code a = code b → a = b)
    (left right : List Row) (raw : List Product) (ws : List Nat)
    (hl : ∀ p ∈ left, allFit f p) (hr : ∀ p ∈ right, allFit f p)
    (collected : gather (pairs left right) = some (raw.map (rowOf code))) :
    familyContains f ((normalize raw).map (rowOf code)) ws ↔
       familyContains f left ws ∧ familyContains f right ws := by
  have valid := gathered_fit f _ _ (by
    intro p hp; simp [pairs] at hp
    obtain ⟨l,h₁,r,h₂,rfl⟩ := hp
    exact ⟨hl l h₁,hr r h₂⟩) collected
  have wf : ∀ p ∈ raw, ∀ c ∈ p, fits f (project code c) := by
    intro p hp c hc
    exact valid (rowOf code p) (List.mem_map_of_mem hp) _ (List.mem_map_of_mem hc)
  exact (normalized_denotation f code inj raw wf ws).trans (family_semantics f left right _ ws hl hr collected)


/-- The statement of each left-fold step records its actual raw pairs and normalized result.
This relation admits any finite number of operands and retains the typed-empty state as an empty family. -/
inductive StagesBy (collect : List (Row × Row) → Option (List Row)) (f : Forest) (code : AtomKey → Nat) : List Row → List (List Row) → List Row → Prop where
  | done (a) : StagesBy collect f code a [] a
  | next {a b bs raw out} : (∀ p ∈ a, allFit f p) → (∀ p ∈ b, allFit f p) →
      collect (pairs a b) = some (raw.map (rowOf code)) →
      StagesBy collect f code ((normalize raw).map (rowOf code)) bs out →
      StagesBy collect f code a (b :: bs) out

abbrev Stages := StagesBy gather

theorem fold_semantics (f : Forest) (code : AtomKey → Nat) (inj : ∀ {a b}, code a = code b → a = b)
    {first operands result} (stages : Stages f code first operands result) (ws : List Nat) :
    familyContains f result ws ↔ familyContains f first ws ∧ ∀ r ∈ operands, familyContains f r ws := by
  induction stages with
  | done => simp
  | next ha hb hit tail ih =>
    rw [ih, normalized_intersection f code inj _ _ _ ws ha hb hit]
    simp only [List.mem_cons,forall_eq_or_imp]
    grind


/-- Interpret each returned source instruction at its own coordinate. A retained carrier
must agree with the returned meet. A divergent instruction must carry no meet. -/
def decodedProduct (ops : List Replay.Operation) : Row → Row → Outcome
  | [], [] => .keep []
  | l :: ls, r :: rs =>
    match Replay.eval ops l r with
    | none => .unsupported
    | some answer =>
      match answer.rule with
      | .exact =>
        if answer.meet = some l.head then
          let representative := if l.authority.isNone && r.authority.isSome then r else l
          prepend representative (decodedProduct ops ls rs)
        else .unsupported
      | .left =>
        if answer.meet = some l.head then prepend l (decodedProduct ops ls rs) else .unsupported
      | .right =>
        if answer.meet = some r.head then prepend r (decodedProduct ops ls rs) else .unsupported
      | .divergent => if answer.meet.isNone then .dropped else .unsupported
  | _, _ => .unsupported

theorem decoded_product (program : List String) (ops : List Replay.Operation)
    (read : Replay.readProgram program = some ops) (l r : Row) :
    decodedProduct ops l r = product l r := by
  have registered := Replay.readProgram_registered program ops read
  induction l generalizing r with
  | nil => cases r <;> rfl
  | cons h t ih =>
    cases r with
    | nil => rfl
    | cons k ks =>
      rw [decodedProduct, Replay.compiler_returns ops h k registered]
      cases e : classify h k <;> simp [product, e, chosen, ih]

theorem decoded_omission (program : List String) (ops : List Replay.Operation)
    (read : Replay.readProgram program = some ops) (l r : Row) :
    decodedProduct ops l r = .dropped ↔ OmittedAt l r := by
  rw [decoded_product program ops read, product_omission]

theorem decoded_explicit_univ (program : List String) (ops : List Replay.Operation)
    (read : Replay.readProgram program = some ops) (l u : Col) (root : u.parents = [])
    (s : shared l u) (member : u.head ∈ l.parents) (ne : l.head ≠ u.head) :
    decodedProduct ops [u] [u] = .keep [u] ∧
    decodedProduct ops [l] [u] = .keep [l] ∧ decodedProduct ops [u] [l] = .keep [l] := by
  obtain ⟨left,right⟩ := explicit_univ l u root s member ne
  have exactCase := (classify_exact u u).2 rfl
  simp [decoded_product program ops read, product, chosen, prepend, left, right, exactCase]

theorem decoded_univ_divergence (program : List String) (ops : List Replay.Operation)
    (read : Replay.readProgram program = some ops) (l r : Col) (ls rs : Row) (univ : Nat)
    (ne : l.head ≠ r.head) (s : shared l r) (nl : r.head ∉ l.parents) (nr : l.head ∉ r.parents)
    (first : firstCommon l r = some univ) :
    Replay.eval ops l r = some ⟨.divergent,none,univ,Replay.through univ l.path,Replay.through univ r.path⟩ ∧
      decodedProduct ops (l :: ls) (r :: rs) = .dropped := by
  have h := diverging_concretes_at_univ l r univ ne s nl nr first
  have registered := Replay.readProgram_registered program ops read
  simp [Replay.compiler_returns ops l r registered, decoded_product program ops read, product, h, chosen]

/-- Apply the interpreted operations to each pair in the producer's row-major enumeration. -/
def decodedGather (ops : List Replay.Operation) : List (Row × Row) → Option (List Row)
  | [] => some []
  | (l,r) :: rest =>
    match decodedProduct ops l r with
    | .unsupported => none
    | .dropped => decodedGather ops rest
    | .keep row => (decodedGather ops rest).map (row :: ·)

theorem decoded_gather (program : List String) (ops : List Replay.Operation)
    (read : Replay.readProgram program = some ops) : decodedGather ops = gather := by
  funext ps
  induction ps with
  | nil => rfl
  | cons p rest ih =>
    obtain ⟨l,r⟩ := p
    cases answer : product l r <;> simp [decodedGather, decoded_product program ops read, ih, gather, answer]

/-- The stages consume rows computed from the JDK-decoded return operands. Each next
operand sees the normalized result of that same stage, including an empty intermediate. -/
theorem decoded_normalized_fold (transcript : List String) (ops : List Replay.Operation)
    (read : Replay.transcriptProgram transcript = some ops) (f : Forest) (code : AtomKey → Nat)
    (inj : ∀ {a b}, code a = code b → a = b) {first second : List Row} {tail : List (List Row)}
    {result : List Row} (stages : StagesBy (decodedGather ops) f code first (second :: tail) result)
    (atoms : List Nat) :
    familyContains f result atoms ↔ familyContains f first atoms ∧
      familyContains f second atoms ∧ ∀ r ∈ tail, familyContains f r atoms := by
  rw [decoded_gather (Replay.sourceProgram transcript) ops read] at stages
  simpa using fold_semantics f code inj stages atoms

#print axioms decoded_product
#print axioms decoded_omission
#print axioms decoded_explicit_univ
#print axioms decoded_univ_divergence
#print axioms decoded_gather
#print axioms decoded_normalized_fold
#print axioms product_fit
#print axioms gathered_fit
#print axioms fold_semantics

#print axioms group_property
#print axioms same_key
#print axioms grouped_denotation
#print axioms coordinate_below
#print axioms order_properties
#print axioms normalized_denotation
#print axioms normalized_intersection
end A222.Normalized

