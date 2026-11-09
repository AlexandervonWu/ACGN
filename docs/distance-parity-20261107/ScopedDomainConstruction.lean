import Std

/- Constructing an original declaration domain in its lexical prefix is
   sound independently of the rest of the binder body. This is a model of
   the scoped construction boundary, not a Java refinement or wire proof. -/
namespace ScopedDomainConstruction

inductive Term (V : Type) where
  | slot : Nat → Term V
  | atom : V → Term V
  | unary : (V → V) → Term V → Term V
  | binary : (V → V → V) → Term V → Term V → Term V

def inScope (n : Nat) : Term V → Prop
  | .slot i => i < n
  | .atom _ => True
  | .unary _ x => inScope n x
  | .binary _ x y => inScope n x ∧ inScope n y

def eval (env : Nat → V) : Term V → V
  | .slot i => env i
  | .atom v => v
  | .unary f x => f (eval env x)
  | .binary f x y => f (eval env x) (eval env y)

theorem prefix_preserves_domain (n : Nat) (a b : Nat → V) (t : Term V)
    (scope : inScope n t) (same : ∀ i, i < n → a i = b i) :
    eval a t = eval b t := by
  induction t with
  | slot i => exact same i scope
  | atom v => rfl
  | unary f x ih => exact congrArg f (ih scope)
  | binary f x y ihx ihy =>
    change f (eval a x) (eval a y) = f (eval b x) (eval b y)
    rw [ihx scope.1, ihy scope.2]

theorem current_and_future_not_in_prefix (n i : Nat) (later : n ≤ i) :
    ¬ inScope n (Term.slot i : Term V) := Nat.not_lt.mpr later

-- Q may be ALL, SOME, ONE, or LONE. No exchange or hoisting law is assumed.
theorem declaration_congruence (Q : (V → Prop) → Prop)
    (d e body : V → Prop) (domain : ∀ v, d v ↔ e v) :
    Q (fun v => d v ∧ body v) ↔ Q (fun v => e v ∧ body v) := by
  have same : d = e := funext fun v => propext (domain v)
  rw [same]

def join (r : A → B → Prop) (s : B → C → Prop) : A → C → Prop :=
  fun a c => ∃ b, r a b ∧ s b c

theorem typed_join_rotation (r : A → B → Prop) (s : B → C → Prop)
    (t : C → D → Prop) (a : A) (d : D) :
    join (join r s) t a d ↔ join r (join s t) a d := by
  constructor
  · rintro ⟨c, ⟨b, hr, hs⟩, ht⟩
    exact ⟨b, hr, c, hs, ht⟩
  · rintro ⟨b, hr, c, hs, ht⟩
    exact ⟨c, ⟨b, hr, hs⟩, ht⟩

#print axioms prefix_preserves_domain
#print axioms current_and_future_not_in_prefix
#print axioms declaration_congruence
#print axioms typed_join_rotation
end ScopedDomainConstruction
