import Std
import GuardedJoinRotation

namespace EndpointCanonicalContracts

-- Only a typed two-boundary middle relation licenses this rotation. Retained
-- tuple carriers may be empty; no unary-middle associativity law is added.
theorem join_rotation (r : L → B → Prop) (s : B → M → C → Prop)
    (t : C → R → Prop) (l : L) (m : M) (v : R) :
    GuardedJoinRotation.rightAssociated r s t l m v ↔
      GuardedJoinRotation.leftAssociated r s t l m v :=
  GuardedJoinRotation.local_rotation r s t l m v

-- A common atom carrier retains the empty Person/Course join boundary. The
-- transpose is enrolled q p, NOT enrolled p q. Both groupings keep Grade.
def filteredLeft (grades : A → A → A → Prop) (grade : A → Prop) (c p : A) : Prop :=
  ∃ g, (∃ b, b = c ∧ grades b p g) ∧ grade g
def filteredRight (grades : A → A → A → Prop) (grade : A → Prop) (c p : A) : Prop :=
  ∃ b, b = c ∧ ∃ g, grades b p g ∧ grade g

theorem grade_filter_rotation (grades : A → A → A → Prop) (grade : A → Prop)
    (c p : A) : filteredRight grades grade c p ↔ filteredLeft grades grade c p :=
  GuardedJoinRotation.local_rotation (fun (_ : Unit) b => b = c) grades
    (fun g (_ : Unit) => grade g) () p ()

def courseRight (grades : A → A → A → Prop) (grade : A → Prop)
    (enrolled : A → A → Prop) (c q : A) : Prop :=
  ∃ b, b = c ∧ ∃ p, (∃ g, grades b p g ∧ grade g) ∧ enrolled q p
def courseLeft (grades : A → A → A → Prop) (grade : A → Prop)
    (enrolled : A → A → Prop) (c q : A) : Prop :=
  ∃ p, filteredLeft grades grade c p ∧ enrolled q p

theorem event82_join (grades : A → A → A → Prop) (grade : A → Prop)
    (enrolled : A → A → Prop) (c q : A) :
    courseRight grades grade enrolled c q ↔ courseLeft grades grade enrolled c q := by
  have outer := GuardedJoinRotation.local_rotation (fun (_ : Unit) b => b = c)
    (fun b (_ : Unit) p => ∃ g, grades b p g ∧ grade g) (fun p q => enrolled q p) () () q
  change courseRight grades grade enrolled c q ↔
    (∃ p, filteredRight grades grade c p ∧ enrolled q p) at outer
  rw [outer]
  exact exists_congr fun p => and_congr (grade_filter_rotation grades grade c p) Iff.rfl

theorem event82_context (grades : A → A → A → Prop) (grade : A → Prop)
    (enrolled : A → A → Prop) (c : A)
    (context : (A → Prop) → Prop) :
    context (courseRight grades grade enrolled c) ↔
      context (courseLeft grades grade enrolled c) := by
  have eq : courseRight grades grade enrolled c = courseLeft grades grade enrolled c :=
    funext fun q => propext (event82_join grades grade enrolled c q)
  rw [eq]

structure CourseTyping (course person grade : A → Prop)
    (grades : A → A → A → Prop) (enrolled : A → A → Prop) : Prop where
  gradesTyped : ∀ c p g, grades c p g → course c ∧ person p ∧ grade g
  enrolledTyped : ∀ p c, enrolled p c → person p ∧ course c
  disjoint : ∀ a, person a → course a → False

def middleJoin (grades : A → A → A → Prop) (grade : A → Prop)
    (enrolled : A → A → Prop) (c q : A) : Prop :=
  ∃ p, (∃ g, grades c p g ∧ grade g) ∧ enrolled q p

theorem event82_empty_binary (typing : CourseTyping (A := A) course person grade grades enrolled)
    (c q : A) : ¬ middleJoin grades grade enrolled c q := by
  rintro ⟨p, ⟨g, hg, _⟩, he⟩
  exact typing.disjoint p (typing.gradesTyped c p g hg).2.1
    (typing.enrolledTyped q p he).2

theorem event82_empty_unary (typing : CourseTyping (A := A) course person grade grades enrolled)
    (c q : A) : ¬ courseRight grades grade enrolled c q := by
  rintro ⟨b, _, rest⟩
  exact event82_empty_binary typing b q rest

-- Three distinct top-level signature atoms instantiate the actual sort guard.
def courseAtom (a : Fin 3) : Prop := a = 0
def personAtom (a : Fin 3) : Prop := a = 1
def gradeAtom (a : Fin 3) : Prop := a = 2
def gradesExample (c p g : Fin 3) : Prop := c = 0 ∧ p = 1 ∧ g = 2
def enrolledExample (p c : Fin 3) : Prop := p = 1 ∧ c = 0
theorem event82_typing_instance :
    CourseTyping courseAtom personAtom gradeAtom gradesExample enrolledExample := by
  constructor
  · intro c p g h; exact ⟨h.1, h.2.1, h.2.2⟩
  · intro p c h; exact h
  · intro a hp hc
    have bad : (1 : Fin 3) = 0 := hp.symm.trans hc
    contradiction
theorem event82_wrong_transpose_negative :
    (∃ p g, gradesExample 0 p g ∧ gradeAtom g ∧ enrolledExample p 0) ∧
    ¬ courseRight gradesExample gradeAtom enrolledExample 0 0 := by
  constructor
  · exact ⟨1, 2, by simp [gradesExample, gradeAtom, enrolledExample]⟩
  · exact event82_empty_unary event82_typing_instance 0 0

theorem event82_old_head_rejects :
    decide ("JOIN/identity=;type=Rel(AlloySig:Person)" = "VARIABLE/outer:0") = false := by decide

structure Ref where
  owner : Nat
  slot : Nat
  deriving DecidableEq

structure Permutation where
  forward : Nat → Nat
  backward : Nat → Nat
  leftInverse : ∀ i, backward (forward i) = i
  rightInverse : ∀ i, forward (backward i) = i

def renameRef (owner : Nat) (p : Nat → Nat) (r : Ref) : Ref :=
  if r.owner = owner then { r with slot := p r.slot } else r

theorem rename_inverse (owner : Nat) (p : Permutation) (r : Ref) :
    renameRef owner p.backward (renameRef owner p.forward r) = r := by
  cases r with
  | mk o s => by_cases h : o = owner <;> simp [renameRef, h, p.leftInverse]

theorem foreign_owner_unchanged (h : r.owner ≠ owner) : renameRef owner p r = r := by
  simp [renameRef, h]

inductive Expr (V : Type) where
  | var : Ref → Expr V
  | value : V → Expr V
  | unary : (V → V) → Expr V → Expr V
  | binary : (V → V → V) → Expr V → Expr V → Expr V

def eval (env : Ref → V) : Expr V → V
  | .var r => env r
  | .value v => v
  | .unary f x => f (eval env x)
  | .binary f x y => f (eval env x) (eval env y)

def rename (owner : Nat) (p : Nat → Nat) : Expr V → Expr V
  | .var r => .var (renameRef owner p r)
  | .value v => .value v
  | .unary f x => .unary f (rename owner p x)
  | .binary f x y => .binary f (rename owner p x) (rename owner p y)

def transport (owner : Nat) (p : Nat → Nat) (env : Ref → V) : Ref → V :=
  fun r => env (renameRef owner p r)

theorem eval_rename (owner : Nat) (p : Permutation) (env : Ref → V) (e : Expr V) :
    eval (transport owner p.backward env) (rename owner p.forward e) = eval env e := by
  induction e with
  | var r => exact congrArg env (rename_inverse owner p r)
  | value v => rfl
  | unary f x ih => exact congrArg f ih
  | binary f x y ihx ihy => simp only [rename, eval, ihx, ihy]

theorem transport_inverse (owner : Nat) (p : Permutation) (env : Ref → V) :
    transport owner p.forward (transport owner p.backward env) = env := by
  funext r
  exact congrArg env (rename_inverse owner p r)

def reverse (p : Permutation) : Permutation :=
  ⟨p.backward, p.forward, p.rightInverse, p.leftInverse⟩

theorem transport_inverse_other (owner : Nat) (p : Permutation) (env : Ref → V) :
    transport owner p.backward (transport owner p.forward env) = env :=
  transport_inverse owner (reverse p) env

-- Quantify over the same complete valuations. Transport domains, dependency
-- guards and the body together; this does not exchange dependent declarations.
theorem all_transport (f g : A → A) (fg : ∀ x, f (g x) = x)
    (p : A → Prop) :
    (∀ x, p (f x)) ↔ (∀ x, p x) := by
  constructor
  · intro h x; simpa [fg x] using h (g x)
  · intro h x; exact h (f x)

theorem some_transport (f g : A → A) (fg : ∀ x, f (g x) = x)
    (p : A → Prop) : (∃ x, p (f x)) ↔ (∃ x, p x) := by
  constructor
  · rintro ⟨x, hx⟩; exact ⟨f x, hx⟩
  · rintro ⟨x, hx⟩; exact ⟨g x, by simpa [fg x] using hx⟩

def lone (p : A → Prop) : Prop := ∀ x y, p x → p y → x = y
def one (p : A → Prop) : Prop := (∃ x, p x) ∧ lone p

theorem event82_full_inv12 (course student grade : A → Prop)
    (grades : A → A → A → Prop) (enrolled : A → A → Prop) :
    (∀ c, course c → ∀ s, student s →
      one (fun q => enrolled s q ∧ courseRight grades grade enrolled c q)) ↔
    (∀ c, course c → ∀ s, student s →
      one (fun q => enrolled s q ∧ courseLeft grades grade enrolled c q)) := by
  have eq : courseRight grades grade enrolled = courseLeft grades grade enrolled :=
    funext fun c => funext fun q => propext (event82_join grades grade enrolled c q)
  rw [eq]

theorem lone_transport (f g : A → A) (fg : ∀ x, f (g x) = x)
    (gf : ∀ x, g (f x) = x) (p : A → Prop) :
    lone (fun x => p (f x)) ↔ lone p := by
  constructor
  · intro h x y hx hy
    have same := h (g x) (g y) (by simpa [fg x] using hx) (by simpa [fg y] using hy)
    have applied := congrArg f same
    simpa only [fg] using applied
  · intro h x y hx hy
    have same := congrArg g (h (f x) (f y) hx hy)
    simpa only [gf] using same

theorem one_transport (f g : A → A) (fg : ∀ x, f (g x) = x)
    (gf : ∀ x, g (f x) = x) (p : A → Prop) :
    one (fun x => p (f x)) ↔ one p :=
  and_congr (some_transport f g fg p) (lone_transport f g fg gf p)

structure Descriptor where
  owner : Nat
  phase : Nat
  exactType : Nat
  domain : Nat
  dependency : List Nat
  role : Nat
  disjointGroup : Nat
  deriving DecidableEq

def typedPermutation (ds : Nat → Descriptor) (p : Permutation) : Prop :=
  ∀ i, ds (p.forward i) = ds i

theorem descriptor_preserved (h : typedPermutation ds p) (i : Nat) :
    ds (p.forward i) = ds i := h i

def swap01 (i : Nat) : Nat := if i = 0 then 1 else if i = 1 then 0 else i
theorem swap_twice (i : Nat) : swap01 (swap01 i) = i := by
  by_cases h0 : i = 0
  · subst i; decide
  · by_cases h1 : i = 1
    · subst i; decide
    · simp [swap01, h0, h1]
def swap : Permutation := ⟨swap01, swap01, swap_twice, swap_twice⟩

def workstation : Descriptor := ⟨0, 0, 1, 1, [], 0, 0⟩
def finiteSwap (i : Fin 2) : Fin 2 := if i = 0 then 1 else 0
theorem finiteSwap_inverse : ∀ i, finiteSwap (finiteSwap i) = i := by decide
def workstationDeclarations : Fin 2 → Descriptor := fun _ => workstation
theorem event1495_typed :
    ∀ i, workstationDeclarations (finiteSwap i) = workstationDeclarations i := by decide
theorem finiteSwap_matches : ∀ i : Fin 2, (finiteSwap i).val = swap01 i.val := by decide
theorem slots_outside_block_fixed (i : Nat) (outside : 2 ≤ i) : swap01 i = i := by
  simp [swap01, show i ≠ 0 by omega, show i ≠ 1 by omega]
theorem event1495_old_head_rejects : decide (Ref.mk 0 0 = Ref.mk 0 1) = false := by decide
theorem event1495_old_source_head_rejects :
    decide ("VARIABLE/local:0:0" = "VARIABLE/local:0:1") = false := by decide
theorem owner0_swap_eval_forward (env : Ref → V) (body : Expr V) :
    eval (transport 0 swap.backward env) (rename 0 swap.forward body) = eval env body :=
  eval_rename 0 swap env body
theorem owner0_swap_eval_reverse (env : Ref → V) (body : Expr V) :
    eval (transport 0 swap.forward env) (rename 0 swap.backward body) = eval env body :=
  eval_rename 0 (reverse swap) env body

def swapValuation (v : Fin 2 → A) : Fin 2 → A := fun i => v (finiteSwap i)
theorem swapValuation_inverse (v : Fin 2 → A) : swapValuation (swapValuation v) = v := by
  funext i; exact congrArg v (finiteSwap_inverse i)

-- Actual inv9 conjunct: all x,y: Workstation |
-- no succ.x and no y.succ implies x != y.
def workstationBody (succ : W → W → Prop) (x y : W) : Prop :=
  ((¬ ∃ z, succ z x) ∧ (¬ ∃ z, succ y z)) → x ≠ y
def workstationSource (succ : W → W → Prop) : Prop :=
  ∀ v : Fin 2 → W, workstationBody succ (v 0) (v 1)
def workstationSelected (succ : W → W → Prop) : Prop :=
  ∀ v : Fin 2 → W, workstationBody succ (v 1) (v 0)

theorem workstation_matrix (succ : W → W → Prop) (x y : W) :
    workstationBody succ x y ↔ (x ≠ y ∨ (∃ z, succ z x) ∨ (∃ z, succ y z)) := by
  classical
  by_cases incoming : ∃ z, succ z x <;> by_cases outgoing : ∃ z, succ y z <;>
    simp [workstationBody, incoming, outgoing]

theorem event1495_body_transport (succ : W → W → Prop) (v : Fin 2 → W) :
    workstationBody succ (swapValuation v 1) (swapValuation v 0) ↔
      workstationBody succ (v 0) (v 1) := by rfl

theorem event1495_forward (succ : W → W → Prop) :
    workstationSelected succ ↔ workstationSource succ :=
  all_transport swapValuation swapValuation swapValuation_inverse
    (fun v => workstationBody succ (v 0) (v 1))
theorem event1495_reverse (succ : W → W → Prop) :
    workstationSource succ ↔ workstationSelected succ := (event1495_forward succ).symm

theorem workstation_source_syntax (succ : W → W → Prop) :
    workstationSource succ ↔ (∀ x y, workstationBody succ x y) := by
  constructor
  · intro h x y
    exact h (fun i => if i = 0 then x else y)
  · intro h v; exact h (v 0) (v 1)

theorem event1495_predicate_context (succ : W → W → Prop) (acyclic separated : Prop) :
    (acyclic ∧ workstationSource succ ∧ separated) ↔
      (acyclic ∧ workstationSelected succ ∧ separated) :=
  and_congr Iff.rfl (and_congr (event1495_reverse succ) Iff.rfl)
theorem nested_owner_fixed : renameRef 0 swap01 ⟨1, 0⟩ = ⟨1, 0⟩ := by decide
theorem bad_capture_changes_value :
    eval (fun r => r.slot) (.var ⟨0, 0⟩) ≠
      eval (fun r => r.slot) (rename 0 swap01 (.var ⟨0, 0⟩)) := by decide
theorem wrong_type_rejected :
    ¬ typedPermutation (fun i => { workstation with exactType := i }) swap := by
  intro h
  have bad := congrArg Descriptor.exactType (h 0)
  change 1 = 0 at bad
  contradiction

def conjunction (meaning : A → Prop) (xs : List A) : Prop := ∀ x ∈ xs, meaning x
def disjunction (meaning : A → Prop) (xs : List A) : Prop := ∃ x ∈ xs, meaning x

def dedup [DecidableEq A] : List A → List A
  | [] => []
  | x :: xs => if x ∈ xs then dedup xs else x :: dedup xs

theorem mem_dedup [DecidableEq A] (x : A) (xs : List A) : x ∈ dedup xs ↔ x ∈ xs := by
  induction xs with
  | nil => simp [dedup]
  | cons y ys ih =>
    simp only [dedup]
    split
    · rename_i hy
      rw [ih]
      simp only [List.mem_cons]
      constructor
      · exact Or.inr
      · rintro (rfl | hx) <;> assumption
    · simp only [List.mem_cons, ih]

theorem dedup_and [DecidableEq A] (meaning : A → Prop) (xs : List A) :
    conjunction meaning (dedup xs) ↔ conjunction meaning xs := by
  simp only [conjunction, mem_dedup]
theorem dedup_or [DecidableEq A] (meaning : A → Prop) (xs : List A) :
    disjunction meaning (dedup xs) ↔ disjunction meaning xs := by
  simp only [disjunction, mem_dedup]

theorem normalized_and (meaning : A → Prop) (normalMeaning : B → Prop)
    (normalize : A → B) (sound : ∀ x, normalMeaning (normalize x) ↔ meaning x)
    [DecidableEq B] (xs : List A) :
    conjunction normalMeaning (dedup (xs.map normalize)) ↔ conjunction meaning xs := by
  rw [dedup_and]
  constructor
  · intro h x hx; exact (sound x).mp (h (normalize x) (List.mem_map.mpr ⟨x, hx, rfl⟩))
  · intro h y hy
    obtain ⟨x, hx, rfl⟩ := List.mem_map.mp hy
    exact (sound x).mpr (h x hx)

theorem event1560_dedup (p q : Prop) : (p ∧ q ∧ q) ↔ (p ∧ q) := by
  constructor
  · exact fun h => ⟨h.1, h.2.1⟩
  · exact fun h => ⟨h.1, h.2, h.2⟩
theorem event1560_old_count_rejects : (3 == 2) = false := by decide
theorem duplicate_costs_not_equal : (1 + 1 : Nat) ≠ 1 := by decide
theorem false_dedup_rejected : ¬ ((True ∧ False) ↔ True) := by simp

def userDeclarations : Fin 2 → Descriptor := fun _ => ⟨0, 0, 2, 2, [], 0, 0⟩
def photoDeclaration : Descriptor := ⟨1, 0, 3, 3, [], 0, 0⟩
theorem user_permutation_typed :
    ∀ i, userDeclarations (finiteSwap i) = userDeclarations i := by decide
theorem inner_photo_owner_fixed : renameRef 0 swap01 ⟨photoDeclaration.owner, 0⟩ = ⟨1, 0⟩ := by decide

-- Separate User/Photo carriers instantiate the nested, differently typed owners.
def userBody (follows : U → U → Prop) (sees : U → P → Prop)
    (v : Fin 2 → U) (photo : P) : Prop := follows (v 0) (v 1) → sees (v 0) photo
def userOtherBody (follows : U → U → Prop) (sees : U → P → Prop)
    (v : Fin 2 → U) (photo : P) : Prop := follows (v 1) (v 0) → sees (v 1) photo
def userBranch (follows : U → U → Prop) (sees : U → P → Prop) : Prop :=
  ∀ v : Fin 2 → U, ∀ photo : P, userBody follows sees v photo
def userOtherBranch (follows : U → U → Prop) (sees : U → P → Prop) : Prop :=
  ∀ v : Fin 2 → U, ∀ photo : P, userOtherBody follows sees v photo

theorem user_body_transport (follows : U → U → Prop) (sees : U → P → Prop)
    (v : Fin 2 → U) (photo : P) :
    userOtherBody follows sees (swapValuation v) photo ↔ userBody follows sees v photo := by rfl

theorem user_source_syntax (follows : U → U → Prop) (sees : U → P → Prop) :
    userBranch follows sees ↔ (∀ a b p, follows a b → sees a p) := by
  constructor
  · intro h a b p; exact h (fun i => if i = 0 then a else b) p
  · intro h v p; exact h (v 0) (v 1) p

theorem user_other_source_syntax (follows : U → U → Prop) (sees : U → P → Prop) :
    userOtherBranch follows sees ↔ (∀ a b p, follows b a → sees b p) := by
  constructor
  · intro h a b p; exact h (fun i => if i = 0 then a else b) p
  · intro h v p; exact h (v 0) (v 1) p

theorem event1560_branches_equivalent (follows : U → U → Prop) (sees : U → P → Prop) :
    userOtherBranch follows sees ↔ userBranch follows sees :=
  all_transport swapValuation swapValuation swapValuation_inverse
    (fun v => ∀ photo, userBody follows sees v photo)

def adClause (isAd isInfluencer : A → Prop) (posts : A → A → Prop) : Prop :=
  ∀ a, isAd a → one (fun u => isInfluencer u ∧ posts u a)

theorem event1560_full_inv3 (isAd isInfluencer : A → Prop) (posts sees follows : A → A → Prop)
    (isUser isPhoto : A → Prop) :
    let users := {a // isUser a}
    let photos := {a // isPhoto a}
    let f : users → users → Prop := fun a b => follows a.val b.val
    let s : users → photos → Prop := fun a p => sees a.val p.val
    (adClause isAd isInfluencer posts ∧ userBranch f s ∧ userOtherBranch f s) ↔
      (adClause isAd isInfluencer posts ∧ userBranch f s) := by
  dsimp
  rw [event1560_branches_equivalent]
  exact event1560_dedup _ _

theorem nonbijective_slot_map_rejected :
    ¬ ∃ inverse : Fin 2 → Fin 2, ∀ i, inverse ((fun _ : Fin 2 => 0) i) = i := by
  rintro ⟨inverse, h⟩
  have bad : (0 : Fin 2) = 1 := (h 0).symm.trans (h 1)
  contradiction

end EndpointCanonicalContracts
