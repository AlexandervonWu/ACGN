import AdaptivePhaseAlgebra

namespace AdaptiveFutureFrames
open AdaptivePhaseAlgebra

-- Normal forms for a contiguous word of future operators, at any trace position.
inductive Key where
  | now (shift : Nat) | all (shift : Nat) | some (shift : Nat) | recurring | permanent
  deriving DecidableEq, Repr

def Key.eval (p : Nat → Prop) : Key → Nat → Prop
  | .now n => fun t => p (t+n)
  | .all n => fun t => futureAlways p (t+n)
  | .some n => fun t => futureEventually p (t+n)
  | .recurring => fun _ => ∀ i, futureEventually p i
  | .permanent => fun _ => ∃ i, futureAlways p i

def prepend : TimeFrame → Key → Key
  | .after, .now n => .now (n+1)
  | .after, .all n => .all (n+1)
  | .after, .some n => .some (n+1)
  | .always, .now n | .always, .all n => .all n
  | .eventually, .now n | .eventually, .some n => .some n
  | .always, .some _ => .recurring
  | .eventually, .all _ => .permanent
  | _, .recurring => .recurring
  | _, .permanent => .permanent

def key (frames : List TimeFrame) := frames.foldr prepend (.now 0)

private theorem shift_all (p : Nat → Prop) (t n : Nat) :
    futureAlways (fun i => p (i+n)) t ↔ futureAlways p (t+n) := by
  constructor
  · intro h j hj
    simpa [show j-n+n = j by omega] using h (j-n) (by omega)
  · exact fun h j hj => h (j+n) (by omega)

private theorem shift_some (p : Nat → Prop) (t n : Nat) :
    futureEventually (fun i => p (i+n)) t ↔ futureEventually p (t+n) := by
  constructor
  · rintro ⟨j,hj,h⟩; exact ⟨j+n,by omega,h⟩
  · rintro ⟨j,hj,h⟩; exact ⟨j-n,by omega,by simpa only [show j-n+n=j by omega] using h⟩

private theorem modal (p : Nat → Prop) (t : Nat) :
    (futureAlways (futureAlways p) t ↔ futureAlways p t) ∧
    (futureEventually (futureEventually p) t ↔ futureEventually p t) ∧
    (futureAlways (futureEventually p) t ↔ ∀ j, futureEventually p j) ∧
    (futureEventually (futureAlways p) t ↔ ∃ j, futureAlways p j) := by
  refine ⟨⟨fun h => h t (by omega),fun h j hj i hi => h i (by omega)⟩,
    ⟨fun ⟨_,hj,i,hi,yes⟩ => ⟨i,by omega,yes⟩,fun h => ⟨t,by omega,h⟩⟩,
    ⟨?_,fun h j _ => h j⟩,⟨fun ⟨j,_,h⟩ => ⟨j,h⟩,?_⟩⟩
  · intro h j; obtain ⟨i,hi,yes⟩ := h (max j t) (by omega)
    exact ⟨i,by omega,yes⟩
  · rintro ⟨j,h⟩; exact ⟨max j t,by omega,fun i hi => h i (by omega)⟩

theorem prepend_sound (op : TimeFrame) (k : Key) (p : Nat → Prop) (t : Nat) :
    inFrames [op] (Key.eval p k) t ↔ Key.eval p (prepend op k) t := by
  have stableAll (a : Prop) : futureAlways (fun _ => a) t ↔ a :=
    ⟨fun h => h t (by omega),fun h _ _ => h⟩
  have stableSome (a : Prop) : futureEventually (fun _ => a) t ↔ a :=
    ⟨fun ⟨_,_,h⟩ => h,fun h => ⟨t,by omega,h⟩⟩
  cases op <;> cases k <;> simp only [inFrames, prepend, Key.eval, Nat.add_assoc,
    Nat.add_comm 1, shift_all, shift_some, stableAll, stableSome,
    (modal p _).1, (modal p _).2.1, (modal p _).2.2.1, (modal p _).2.2.2]

theorem sound (word : List TimeFrame) (p : Nat → Prop) (t : Nat) :
    inFrames word p t ↔ Key.eval p (key word) t := by
  induction word generalizing t with
  | nil => rfl
  | cons op rest ih =>
    have e := funext fun i => propext (ih i)
    have step := prepend_sound op (key rest) p t
    cases op <;> simpa only [key,List.foldr_cons,inFrames,e] using step

theorem compare (left right : List TimeFrame) (p q : Nat → Prop)
    (same : key left = key right) (body : ∀ i, p i ↔ q i) (t : Nat) :
    inFrames left p t ↔ inFrames right q t := by
  rw [sound, sound, same, show p = q from funext fun i => propext (body i)]

-- Source-linked trash_ltl/inv12: the binder belongs to the eventual instant,
-- not to either end of the inner clock shift.
theorem witnessed_unfold (d s : Nat → Rel α) (frames : List TimeFrame)
    (k : key frames = .all 1) (t : Nat) :
    futureEventually (fun i => qSome (d i) (fun x => s i x ∧ inFrames frames (fun j => s j x) i)) t ↔
    futureEventually (fun i => qSome (d i) (fun x => futureAlways (fun j => s j x) i)) t := by
  simpa only [sound,k,Key.eval] using eventual_witness_always_unfold d s t

theorem persistent_members (d s : Nat → Rel α) (frames : List TimeFrame)
    (k : key frames = .all 1) (t : Nat) (typed : futureAlways (fun i => subset (s i) (d i)) t) :
    futureAlways (fun i => qAll (d i) (fun x => s i x → inFrames frames (fun j => s j x) i)) t ↔
    futureAlways (fun i => subset (s i) (s (i+1))) t := by
  simp only [sound,k,Key.eval]
  exact persistence_iff_next_subset d s t typed

theorem reordered_instance :
    let file : Nat → Rel Unit := fun i _ => 0 < i
    let trash : Nat → Rel Unit := fun i _ => 1 < i
    ([TimeFrame.always,.after] ≠ [.after,.always]) ∧
    (futureAlways (fun i => qAll (file i) (fun x => trash i x →
      inFrames [.always,.after] (fun j => trash j x) i)) 0 ↔
      futureAlways (fun i => subset (trash i) (trash (i+1))) 0) := by
  intro file trash
  constructor
  · intro h
    cases h
  · apply persistent_members file trash [.always,.after] rfl
    intro i _ _ h
    change 1 < i at h
    change 0 < i
    omega

theorem separated :
    Key.eval (fun i => i%2=0) .recurring 0 ∧ ¬Key.eval (fun i => i%2=0) .permanent 0 := by
  refine ⟨fun i => ⟨2*i,by omega,by omega⟩,?_⟩
  rintro ⟨i,h⟩; have := h (2*i+1) (by omega); omega

end AdaptiveFutureFrames
