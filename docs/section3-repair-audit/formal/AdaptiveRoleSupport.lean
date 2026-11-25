import AdaptiveEndpointBounds

namespace AdaptiveRoleSupport

-- A counterexample query can identify witnesses, but cannot demand distinctness,
-- missing edges, or witnesses for a universal quantifier.
inductive Query where
  | yes | no | role (sign : Bool) (x : Nat) | edge (x y : Nat)
  | sameOwner (x z : Nat) | sameTarget (y z : Nat)
  | conj (p q : Query) | disj (p q : Query) | owner (p : Query) | target (p : Query)
  deriving Repr

structure World (α β : Type) where
  role : α → Bool
  edge : BinaryRel α β

def atOne (xs : List α) (i : Nat) (p : α → Prop) : Prop :=
  ∃ x, xs[i]? = some x ∧ p x

def holds (w : World α β) : Query → List α → List β → Prop
  | .yes, _, _ => True
  | .no, _, _ => False
  | .role s i, xs, _ => atOne xs i (fun x => w.role x = s)
  | .edge i j, xs, ys => atOne xs i (fun x => atOne ys j (w.edge x))
  | .sameOwner i j, xs, _ => atOne xs i (fun x => xs[j]? = some x)
  | .sameTarget i j, _, ys => atOne ys i (fun y => ys[j]? = some y)
  | .conj p q, xs, ys => holds w p xs ys ∧ holds w q xs ys
  | .disj p q, xs, ys => holds w p xs ys ∨ holds w q xs ys
  | .owner p, xs, ys => ∃ x, holds w p (x::xs) ys
  | .target p, xs, ys => ∃ y, holds w p xs (y::ys)

structure Transport (a : World α β) (b : World γ δ) where
  f : α → γ
  g : β → δ
  role : ∀ x, b.role (f x) = a.role x
  edge : ∀ x y, a.edge x y → b.edge (f x) (g y)

private theorem lookup_map (xs : List α) (f : α → β) (i : Nat) (h : xs[i]? = some x) :
    (xs.map f)[i]? = some (f x) := by simp [List.getElem?_map,h]

theorem positive_transport (h : Transport a b) (q : Query) (xs ys) :
    holds a q xs ys → holds b q (xs.map h.f) (ys.map h.g) := by
  induction q generalizing xs ys with
  | yes => exact id
  | no => exact id
  | role s i =>
    rintro ⟨x,hx,r⟩
    exact ⟨h.f x,lookup_map _ _ _ hx,(h.role x).trans r⟩
  | edge i j =>
    rintro ⟨x,hx,y,hy,e⟩
    exact ⟨h.f x,lookup_map _ _ _ hx,h.g y,lookup_map _ _ _ hy,h.edge x y e⟩
  | sameOwner i j => exact fun ⟨x,l,r⟩ => ⟨h.f x,lookup_map _ _ _ l,lookup_map _ _ _ r⟩
  | sameTarget i j => exact fun ⟨y,l,r⟩ => ⟨h.g y,lookup_map _ _ _ l,lookup_map _ _ _ r⟩
  | conj p q hp hq => exact fun ⟨l,r⟩ => ⟨hp _ _ l,hq _ _ r⟩
  | disj p q hp hq => exact Or.imp (hp _ _) (hq _ _)
  | owner p ih => exact fun ⟨x,hx⟩ => ⟨h.f x,ih (x::xs) ys hx⟩
  | target p ih => exact fun ⟨y,hy⟩ => ⟨h.g y,ih xs (y::ys) hy⟩

def bad : World Unit Unit := ⟨fun _ => false,fun _ _ => True⟩
def good : World Bool Unit := ⟨id,fun x _ => x = true⟩
def allowed (w : World α β) := AdaptiveEndpointBounds.inside w.edge (fun x => w.role x = true) univRel

theorem allowed_iff (w : World α β) : allowed w ↔ ∀ x y, w.edge x y → w.role x = true := by
  simp [allowed,AdaptiveEndpointBounds.inside_iff,univRel]

-- One bad edge embeds in any violation. Every allowed world maps into the full
-- allowed template by preserving each owner's role and forgetting target identity.
theorem sandwich (lo hi : Query) (lb : holds bad lo [] []) (ub : ¬holds good hi [] [])
    (w : World α β) (violation : Prop)
    (under : holds w lo [] [] → violation) (over : violation → holds w hi [] []) :
    ¬violation ↔ allowed w := by
  rw [allowed_iff]
  constructor
  · intro h x y e
    cases r : w.role x with
    | true => rfl
    | false =>
      let map : Transport bad w := ⟨fun _ => x,fun _ => y,fun _ => r,fun _ _ _ => e⟩
      exact False.elim (h (under (positive_transport map lo [] [] lb)))
  · intro safe hold
    let map : Transport w good := ⟨w.role,fun _ => (),fun _ => rfl,safe⟩
    exact ub (positive_transport map hi [] [] (over hold))

def evaluate [DecidableEq α] [DecidableEq β] (os : List α) (ts : List β)
    (role : α → Bool) (edge : α → β → Bool) : Query → List α → List β → Bool
  | .yes, _, _ => true
  | .no, _, _ => false
  | .role s i, xs, _ => xs[i]?.any (fun x => role x == s)
  | .edge i j, xs, ys => xs[i]?.any (fun x => ys[j]?.any (edge x))
  | .sameOwner i j, xs, _ => xs[i]?.any (fun x => xs[j]? == some x)
  | .sameTarget i j, _, ys => ys[i]?.any (fun y => ys[j]? == some y)
  | .conj p q, xs, ys => evaluate os ts role edge p xs ys && evaluate os ts role edge q xs ys
  | .disj p q, xs, ys => evaluate os ts role edge p xs ys || evaluate os ts role edge q xs ys
  | .owner p, xs, ys => os.any (fun x => evaluate os ts role edge p (x::xs) ys)
  | .target p, xs, ys => ts.any (fun y => evaluate os ts role edge p xs (y::ys))

theorem evaluate_spec [DecidableEq α] [DecidableEq β] (os : List α) (ts : List β)
    (ho : ∀ x, x ∈ os) (ht : ∀ y, y ∈ ts) (r : α → Bool) (e : α → β → Bool)
    (q : Query) (xs ys) : evaluate os ts r e q xs ys = true ↔
      holds ⟨r,fun x y => e x y = true⟩ q xs ys := by
  induction q generalizing xs ys <;> simp [evaluate, holds, atOne, Option.any_eq_true,
    List.any_eq_true, *]

def accepts (lo hi : Query) :=
  evaluate [()] [()] (fun _ => false) (fun _ _ => true) lo [] [] &&
    !evaluate [false,true] [()] id (fun x _ => x) hi [] []

theorem accepted_sound (lo hi : Query) (h : accepts lo hi = true) (w : World α β) (v : Prop)
    (lower : holds w lo [] [] → v) (upper : v → holds w hi [] []) : ¬v ↔ allowed w := by
  rcases Bool.and_eq_true_iff.mp h with ⟨lb,ub⟩
  apply sandwich lo hi _ _ w v lower upper
  · have spec := evaluate_spec [()] [()] (by simp) (by simp) (fun _ => false) (fun _ _ => true) lo [] []
    simpa [bad] using spec.mp lb
  · intro hg
    have spec := evaluate_spec [false,true] [()] (fun x => by cases x <;> simp) (by simp) id (fun x _ => x) hi [] []
    have ht := spec.mpr hg
    simp [ht] at ub

theorem universe_witness (o t p : Rel α) (outside : ∀ a, ¬o a → ¬t a → ¬p a) :
    (∃ a, p a) ↔ (∃ a, o a ∧ p a) ∨ (∃ a, t a ∧ p a) := by
  constructor
  · rintro ⟨a,h⟩
    by_cases ho : o a
    · exact Or.inl ⟨a,ho,h⟩
    by_cases ht : t a
    · exact Or.inr ⟨a,ht,h⟩
    exact (outside a ho ht h).elim
  · rintro (⟨a,_,h⟩ | ⟨a,_,h⟩) <;> exact ⟨a,h⟩

theorem singleton_upper (r : BinaryRel α β) (x : α) (y : β)
    (eq : unaryLeftJoin (singletonRel x) r = singletonRel y) : r x y := by
  rw [AdaptiveRelationalImage.singleton_fiber] at eq
  exact eq.symm ▸ (show singletonRel y y from rfl)

theorem occupied_rows (w : World α β) :
    (∀ x, (∃ y, w.edge x y) → w.role x = true) ↔ allowed w := by
  rw [allowed_iff]
  exact ⟨fun h x y he => h x ⟨y,he⟩, fun h x ⟨y,he⟩ => h x y he⟩

theorem singleton_supplement (w : World α β) :
    ((∀ x, (∃ y, w.edge x y) → w.role x = true) ∧
     (∀ x y, unaryLeftJoin (singletonRel x) w.edge = singletonRel y → w.role x = true)) ↔ allowed w := by
  exact ⟨fun h => (occupied_rows w).mp h.1,fun h =>
    ⟨(occupied_rows w).mpr h,fun x y eq => (allowed_iff w).mp h x y (singleton_upper _ _ _ eq)⟩⟩

end AdaptiveRoleSupport
