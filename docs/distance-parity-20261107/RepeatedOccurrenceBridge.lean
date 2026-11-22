import RepeatedOccurrenceTransport

/-!
Slot 9 (`AMBIGUOUS_OCCURRENCE_BIJECTION`), part 2 of 2: the replacement gate,
the per-parent assignment loop and the whole endpoint bridge.

Keys are opaque. `skeys` are the structural keys Java already compares
(strings); `pkeys` are provenance keys (codes of the authenticated
source-occurrence provenance of a certified child). Nothing here assumes that
equal keys imply equal trees.

Gate (`provOccurrence`). No unused structural candidate: unsupported, as
before. Structural class of size at most one: that candidate, as before.
Otherwise the unused candidates whose provenance key equals the fast child's:
none is ambiguous (no authenticated transport); else the lowest one, admitted
only when every other such candidate is a deep twin of it.

Proved here:
* the gate equals the old gate whenever the old gate did not answer ambiguous
  in a singleton class, and a parent the old loop completed gets the identical
  assignment (`loop_ok_preserved`); an old unsupported refusal stays
  unsupported (`loop_unsupported_preserved`);
* a completed loop is key preserving, provenance preserving in every ambiguous
  class, injective, covers every certified child when the child counts agree,
  and every certified sibling admitted for a fast child is the same labelled
  subtree as the chosen one (`loop_sound`, `loop_injective`, `loop_covers`);
* for a bridge built by the gate (`GateBuilt`), every key-preserving
  alternative bridge reads the same labelled subtree at every fast occurrence
  (`bridge_reads_agree`), and coincides with it on every occurrence whose
  ancestors' choices were forced (`bridge_forced_unique`); the built bridge is
  injective and covers every certified occurrence;
* hence MATCHED under the built bridges is a resolved correspondence under
  every key-preserving alternative on both endpoints (`gate_matched_sound`),
  and the ordered verdict is the same for every alternative when all action
  coordinates are forced (`gate_verdict_independent`).

Not claimed: that Java's keys, heads, provenance or child order equal this
model (Java correspondence obligations), nor any non-MATCHED verdict when an
action coordinate passes through a non-forced choice (stays AMBIGUOUS/OPEN).
-/
namespace ACGN.FifthFive.RepeatedOccurrence

/-! ### List helpers -/

theorem lt_of_getElem? {α : Type} : ∀ (l : List α) (i : Nat) (a : α), l[i]? = some a → i < l.length
  | [], _, _, h => by simp at h
  | _ :: _, 0, _, _ => by simp
  | _ :: l, i + 1, a, h => by
    have h' : l[i]? = some a := by simpa using h
    have := lt_of_getElem? l i a h'
    simp only [List.length_cons]
    omega

theorem eq_of_mem_length_le_one {α : Type} :
    ∀ (l : List α), l.length ≤ 1 → ∀ a b, a ∈ l → b ∈ l → a = b
  | [], _, _, _, ha, _ => by cases ha
  | [x], _, a, b, ha, hb => by
    have h1 : a = x := by simpa using ha
    have h2 : b = x := by simpa using hb
    rw [h1, h2]
  | _ :: _ :: _, h, _, _, _, _ => by
    simp only [List.length_cons] at h
    omega

theorem nodup_index_inj : ∀ (l : List Nat) (i j x : Nat), l.Nodup →
    l[i]? = some x → l[j]? = some x → i = j
  | [], _, _, _, _, h, _ => by simp at h
  | _ :: _, 0, 0, _, _, _, _ => rfl
  | a :: l, 0, j + 1, x, hn, hi, hj => by
    have h1 : a = x := by simpa using hi
    have h2 : l[j]? = some x := by simpa using hj
    have hx : x ∈ l := List.mem_of_getElem? h2
    exact absurd (h1 ▸ hx) (List.nodup_cons.mp hn).1
  | a :: l, i + 1, 0, x, hn, hi, hj => by
    have h1 : a = x := by simpa using hj
    have h2 : l[i]? = some x := by simpa using hi
    have hx : x ∈ l := List.mem_of_getElem? h2
    exact absurd (h1 ▸ hx) (List.nodup_cons.mp hn).1
  | _ :: l, i + 1, j + 1, x, hn, hi, hj => by
    have h1 : l[i]? = some x := by simpa using hi
    have h2 : l[j]? = some x := by simpa using hj
    rw [nodup_index_inj l i j x (List.nodup_cons.mp hn).2 h1 h2]

/-- Pigeonhole: a duplicate-free list of `n` numbers below `n` contains each. -/
theorem nodup_bounded_covers : ∀ (n : Nat) (l : List Nat), l.Nodup → l.length = n →
    (∀ x ∈ l, x < n) → ∀ j, j < n → j ∈ l
  | 0, _, _, _, _, j, hj => absurd hj (Nat.not_lt_zero j)
  | n + 1, l, hnd, hlen, hlt, j, hj => by
    by_cases hn : n ∈ l
    · have hnd' : (l.erase n).Nodup := hnd.erase n
      have hlen' : (l.erase n).length = n := by
        rw [List.length_erase_of_mem hn, hlen]
        omega
      have hlt' : ∀ x ∈ l.erase n, x < n := by
        intro x hx
        have hx' := (List.Nodup.mem_erase_iff hnd).mp hx
        have := hlt x hx'.2
        omega
      by_cases hjn : j = n
      · rw [hjn]; exact hn
      · exact List.mem_of_mem_erase
          (nodup_bounded_covers n (l.erase n) hnd' hlen' hlt' j (by omega))
    · exfalso
      cases l with
      | nil => simp at hlen
      | cons y t =>
        have hy1 := hlt y (List.mem_cons_self ..)
        have hy2 : y ≠ n := fun e => hn (by rw [← e]; exact List.mem_cons_self ..)
        have hnd' := List.nodup_cons.mp hnd
        have hin : y ∈ t :=
          nodup_bounded_covers n t hnd'.2 (by simpa using hlen)
            (fun x hx => by
              have h1 := hlt x (List.mem_cons_of_mem _ hx)
              have h2 : x ≠ n := fun e => hn (by rw [← e]; exact List.mem_cons_of_mem _ hx)
              omega)
            y (by omega)
        exact hnd'.1 hin

/-! ### Gates -/

inductive Pick where
  | found (index : Nat)
  | ambiguous
  | unsupported
  deriving DecidableEq

def candidates (keys : List String) (key : String) (used : List Nat) : List Nat :=
  (List.range keys.length).filter fun i => !used.contains i && keys[i]? == some key

/-- The Java gate before this slot: exactly one unused equal-key candidate. -/
def uniqueOccurrence (keys : List String) (key : String) (used : List Nat) : Pick :=
  match candidates keys key used with
  | [] => .unsupported
  | [i] => .found i
  | _ :: _ :: _ => .ambiguous

/-- Number of certified siblings carrying the structural key, used or not. -/
def classSize (keys : List String) (key : String) : Nat := (candidates keys key []).length

/-- Unused structural candidates whose provenance key equals the fast child's. -/
def refined (skeys : List String) (pkeys : List Nat) (skey : String) (pkey : Nat)
    (used : List Nat) : List Nat :=
  (candidates skeys skey used).filter fun i => pkeys[i]? == some pkey

def twinAt (cs : List Tree) (i r : Nat) : Bool :=
  match cs[i]?, cs[r]? with
  | some a, some b => twin a b
  | _, _ => false

/-- Lowest candidate, admitted only when every other candidate is a deep twin. -/
def pickTwin (cs : List Tree) : List Nat → Pick
  | [] => .ambiguous
  | i :: rest => if rest.all (twinAt cs i) then .found i else .ambiguous

/-- The replacement gate. -/
def provOccurrence (cs : List Tree) (skeys : List String) (pkeys : List Nat) (skey : String)
    (pkey : Nat) (used : List Nat) : Pick :=
  match candidates skeys skey used with
  | [] => .unsupported
  | m :: _ =>
    if classSize skeys skey ≤ 1 then .found m
    else pickTwin cs (refined skeys pkeys skey pkey used)

theorem mem_candidates (keys : List String) (key : String) (used : List Nat) (i : Nat) :
    i ∈ candidates keys key used ↔ i ∉ used ∧ keys[i]? = some key := by
  unfold candidates
  rw [List.mem_filter, List.mem_range]
  constructor
  · intro ⟨_, h⟩
    simpa using h
  · intro ⟨h1, h2⟩
    exact ⟨lt_of_getElem? keys i key h2, by simpa using And.intro h1 h2⟩

theorem candidates_filter (keys : List String) (key : String) (used : List Nat) :
    candidates keys key used = (candidates keys key []).filter (fun i => !used.contains i) := by
  unfold candidates
  rw [List.filter_filter]
  congr 1

theorem unused_sub (keys : List String) (key : String) (used : List Nat) (i : Nat)
    (h : i ∈ candidates keys key used) : i ∈ candidates keys key [] :=
  (mem_candidates keys key [] i).mpr ⟨by simp, ((mem_candidates keys key used i).mp h).2⟩

theorem unused_length_le (keys : List String) (key : String) (used : List Nat) :
    (candidates keys key used).length ≤ classSize keys key := by
  unfold classSize
  rw [candidates_filter keys key used]
  exact List.length_filter_le _ _

theorem mem_refined (skeys : List String) (pkeys : List Nat) (skey : String) (pkey : Nat)
    (used : List Nat) (i : Nat) :
    i ∈ refined skeys pkeys skey pkey used ↔
      i ∈ candidates skeys skey used ∧ pkeys[i]? = some pkey := by
  unfold refined
  rw [List.mem_filter]
  simp

theorem twinAt_sound (cs : List Tree) (i r : Nat) (h : twinAt cs i r = true) :
    ∃ a, cs[i]? = some a ∧ cs[r]? = some a := by
  unfold twinAt at h
  split at h
  · rename_i a b ha hb
    exact ⟨a, ha, by rw [hb, twin_sound a b h]⟩
  · cases h

theorem pickTwin_found (cs : List Tree) (l : List Nat) (i : Nat) (h : pickTwin cs l = .found i) :
    ∃ rest, l = i :: rest ∧ rest.all (twinAt cs i) = true := by
  cases l with
  | nil => simp [pickTwin] at h
  | cons x rest =>
    by_cases hall : rest.all (twinAt cs x) = true
    · have e : pickTwin cs (x :: rest) = .found x := by simp [pickTwin, hall]
      rw [e] at h
      cases h
      exact ⟨rest, rfl, hall⟩
    · have e : pickTwin cs (x :: rest) = .ambiguous := by simp [pickTwin, hall]
      rw [e] at h
      cases h

theorem pickTwin_ne_unsupported (cs : List Tree) (l : List Nat) :
    pickTwin cs l ≠ .unsupported := by
  cases l with
  | nil => simp [pickTwin]
  | cons x rest =>
    by_cases hall : rest.all (twinAt cs x) = true
    · simp [pickTwin, hall]
    · simp [pickTwin, hall]

/-- Refusal for a missing candidate is exactly the old refusal. -/
theorem prov_unsupported_iff (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) :
    provOccurrence cs skeys pkeys skey pkey used = .unsupported ↔
      uniqueOccurrence skeys skey used = .unsupported := by
  unfold provOccurrence uniqueOccurrence
  cases candidates skeys skey used with
  | nil => simp
  | cons m ms =>
    have h1 : (if classSize skeys skey ≤ 1 then Pick.found m
        else pickTwin cs (refined skeys pkeys skey pkey used)) ≠ .unsupported := by
      by_cases hs : classSize skeys skey ≤ 1
      · simp [hs]
      · simp [hs, pickTwin_ne_unsupported]
    cases ms with
    | nil => simp [h1]
    | cons m' ms' => simp [h1]

/-- In a structural class of size at most one the gate is the old gate. -/
theorem prov_singleton_class (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) (h : classSize skeys skey ≤ 1) :
    provOccurrence cs skeys pkeys skey pkey used = uniqueOccurrence skeys skey used := by
  have hle := unused_length_le skeys skey used
  unfold provOccurrence uniqueOccurrence
  cases hc : candidates skeys skey used with
  | nil => rfl
  | cons m ms =>
    cases ms with
    | nil => simp [h]
    | cons m' ms' =>
      rw [hc] at hle
      simp only [List.length_cons] at hle
      omega

theorem prov_found_cases (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) (i : Nat)
    (h : provOccurrence cs skeys pkeys skey pkey used = .found i) :
    (classSize skeys skey ≤ 1 ∧ i ∈ candidates skeys skey used) ∨
    (¬ classSize skeys skey ≤ 1 ∧
      pickTwin cs (refined skeys pkeys skey pkey used) = .found i) := by
  unfold provOccurrence at h
  cases hc : candidates skeys skey used with
  | nil => rw [hc] at h; cases h
  | cons m ms =>
    rw [hc] at h
    by_cases hs : classSize skeys skey ≤ 1
    · left
      have h' : m = i := by simpa [hs] using h
      exact ⟨hs, by rw [← h']; exact List.mem_cons_self ..⟩
    · right
      have h' : pickTwin cs (refined skeys pkeys skey pkey used) = Pick.found i := by
        simpa [hs] using h
      exact ⟨hs, h'⟩

/-- A found child is unused, carries the structural key and, in an ambiguous
class, the fast child's provenance key. -/
theorem prov_found_mem (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) (i : Nat)
    (h : provOccurrence cs skeys pkeys skey pkey used = .found i) :
    i ∈ candidates skeys skey used ∧ (2 ≤ classSize skeys skey → pkeys[i]? = some pkey) := by
  rcases prov_found_cases cs skeys pkeys skey pkey used i h with ⟨hs, hi⟩ | ⟨_, hp⟩
  · exact ⟨hi, fun h2 => absurd h2 (by omega)⟩
  · obtain ⟨rest, hr, _⟩ := pickTwin_found cs _ i hp
    have hi : i ∈ refined skeys pkeys skey pkey used := by rw [hr]; exact List.mem_cons_self ..
    have hm := (mem_refined skeys pkeys skey pkey used i).mp hi
    exact ⟨hm.1, fun _ => hm.2⟩

/-- Every unused candidate that the gate could have taken for the same keys is
the chosen index or the same labelled subtree as the chosen one. -/
theorem prov_choice_equal (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) (i : Nat)
    (h : provOccurrence cs skeys pkeys skey pkey used = .found i) (r : Nat)
    (hr : r ∈ candidates skeys skey used)
    (hp : 2 ≤ classSize skeys skey → pkeys[r]? = some pkey) :
    r = i ∨ ∃ a, cs[i]? = some a ∧ cs[r]? = some a := by
  rcases prov_found_cases cs skeys pkeys skey pkey used i h with ⟨hs, hi⟩ | ⟨hs, hpk⟩
  · left
    exact eq_of_mem_length_le_one (candidates skeys skey []) hs r i
      (unused_sub skeys skey used r hr) (unused_sub skeys skey used i hi)
  · obtain ⟨rest, hrest, hall⟩ := pickTwin_found cs _ i hpk
    have hr' : r ∈ refined skeys pkeys skey pkey used :=
      (mem_refined skeys pkeys skey pkey used r).mpr ⟨hr, hp (by omega)⟩
    rw [hrest] at hr'
    rcases List.mem_cons.mp hr' with hri | hin
    · exact Or.inl hri
    · exact Or.inr (twinAt_sound cs i r (List.all_eq_true.mp hall r hin))

theorem prov_ambiguous_class (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) (m : Nat) (ms : List Nat)
    (hc : candidates skeys skey used = m :: ms) (hs : 2 ≤ classSize skeys skey) :
    provOccurrence cs skeys pkeys skey pkey used =
      pickTwin cs (refined skeys pkeys skey pkey used) := by
  have hs' : ¬ classSize skeys skey ≤ 1 := by omega
  unfold provOccurrence
  rw [hc]
  simp [hs']

/-- Ambiguity is kept when no unused candidate carries the fast provenance. -/
theorem prov_unauthenticated_rejected (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) (m : Nat) (ms : List Nat)
    (hc : candidates skeys skey used = m :: ms) (hs : 2 ≤ classSize skeys skey)
    (hr : refined skeys pkeys skey pkey used = []) :
    provOccurrence cs skeys pkeys skey pkey used = .ambiguous := by
  rw [prov_ambiguous_class cs skeys pkeys skey pkey used m ms hc hs, hr]
  rfl

/-- Ambiguity is kept when equal-key, equal-provenance candidates are not twins. -/
theorem prov_nontwin_rejected (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (skey : String) (pkey : Nat) (used : List Nat) (m : Nat) (ms : List Nat)
    (hc : candidates skeys skey used = m :: ms) (hs : 2 ≤ classSize skeys skey)
    (i : Nat) (rest : List Nat) (hr : refined skeys pkeys skey pkey used = i :: rest)
    (h : rest.all (twinAt cs i) = false) :
    provOccurrence cs skeys pkeys skey pkey used = .ambiguous := by
  rw [prov_ambiguous_class cs skeys pkeys skey pkey used m ms hc hs, hr]
  simp [pickTwin, h]

/-! ### The assignment loop at one unordered parent -/

inductive Outcome where
  | ok (assignment : List Nat)
  | ambiguous
  | unsupported
  deriving DecidableEq

def extend (j : Nat) : Outcome → Outcome
  | .ok rest => .ok (j :: rest)
  | .ambiguous => .ambiguous
  | .unsupported => .unsupported

def continueWith (p : Pick) (next : Nat → Outcome) : Outcome :=
  match p with
  | .found j => extend j (next j)
  | .ambiguous => .ambiguous
  | .unsupported => .unsupported

/-- The Java loop before this slot, over the fast children's structural keys. -/
def loopOld (skeys : List String) : List String → List Nat → Outcome
  | [], _ => .ok []
  | k :: ks, used =>
    continueWith (uniqueOccurrence skeys k used) fun j => loopOld skeys ks (j :: used)

/-- The replacement loop, over the fast children's structural and provenance keys. -/
def loopNew (cs : List Tree) (skeys : List String) (pkeys : List Nat) :
    List (String × Nat) → List Nat → Outcome
  | [], _ => .ok []
  | (k, p) :: ks, used =>
    continueWith (provOccurrence cs skeys pkeys k p used) fun j =>
      loopNew cs skeys pkeys ks (j :: used)

/-- Row assigned at one corresponded parent: index identity for an ordered
parent (the gate is not consulted), the loop for an unordered one. -/
def assignRow (unordered : Bool) (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (fs : List (String × Nat)) : Outcome :=
  if unordered then loopNew cs skeys pkeys fs [] else .ok (List.range fs.length)

theorem assignRow_ordered (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (fs : List (String × Nat)) :
    assignRow false cs skeys pkeys fs = .ok (List.range fs.length) := rfl

theorem continueWith_ok (p : Pick) (next : Nat → Outcome) (perm : List Nat)
    (h : continueWith p next = .ok perm) :
    ∃ x rest, p = .found x ∧ next x = .ok rest ∧ perm = x :: rest := by
  cases p with
  | found x =>
    cases hn : next x with
    | ok rest =>
      have e : continueWith (.found x) next = .ok (x :: rest) := by
        simp [continueWith, extend, hn]
      rw [e] at h
      cases h
      exact ⟨x, rest, rfl, hn, rfl⟩
    | ambiguous => simp [continueWith, extend, hn] at h
    | unsupported => simp [continueWith, extend, hn] at h
  | ambiguous => simp [continueWith] at h
  | unsupported => simp [continueWith] at h

theorem continueWith_unsupported (p : Pick) (next : Nat → Outcome)
    (h : continueWith p next = .unsupported) :
    p = .unsupported ∨ ∃ x, p = .found x ∧ next x = .unsupported := by
  cases p with
  | found x =>
    right
    cases hn : next x with
    | ok rest => simp [continueWith, extend, hn] at h
    | ambiguous => simp [continueWith, extend, hn] at h
    | unsupported => exact ⟨x, rfl, hn⟩
  | ambiguous => simp [continueWith] at h
  | unsupported => exact Or.inl rfl

theorem unique_found (skeys : List String) (k : String) (used : List Nat) (x : Nat)
    (h : uniqueOccurrence skeys k used = .found x) : candidates skeys k used = [x] := by
  unfold uniqueOccurrence at h
  cases hc : candidates skeys k used with
  | nil => rw [hc] at h; cases h
  | cons m ms =>
    rw [hc] at h
    cases ms with
    | nil =>
      have e : m = x := by simpa using h
      rw [e]
    | cons m' ms' => cases h

/-- Every used certified child is alone in its structural-key class. -/
def UsedSingleton (skeys : List String) (used : List Nat) : Prop :=
  ∀ j ∈ used, ∀ k, skeys[j]? = some k → classSize skeys k ≤ 1

theorem singleton_of_unique (skeys : List String) (k : String) (used : List Nat) (x : Nat)
    (hu : UsedSingleton skeys used) (h : candidates skeys k used = [x]) :
    classSize skeys k ≤ 1 := by
  by_cases hex : ∃ y, y ∈ candidates skeys k [] ∧ y ∈ used
  · obtain ⟨y, hy, hyu⟩ := hex
    exact hu y hyu k ((mem_candidates skeys k [] y).mp hy).2
  · have hall : ∀ y ∈ candidates skeys k [], (!used.contains y) = true := by
      intro y hy
      have hyn : y ∉ used := fun hyu => hex ⟨y, hy, hyu⟩
      simpa using hyn
    have hfil : candidates skeys k used = candidates skeys k [] := by
      rw [candidates_filter skeys k used]
      exact List.filter_eq_self.mpr hall
    unfold classSize
    rw [← hfil, h]
    simp

theorem usedSingleton_cons (skeys : List String) (k : String) (used : List Nat) (x : Nat)
    (hu : UsedSingleton skeys used) (hc : candidates skeys k used = [x])
    (hs : classSize skeys k ≤ 1) : UsedSingleton skeys (x :: used) := by
  intro j hj k' hk'
  rcases List.mem_cons.mp hj with hjx | hj'
  · have hx : x ∈ candidates skeys k used := by rw [hc]; exact List.mem_cons_self ..
    have hk : skeys[x]? = some k := ((mem_candidates skeys k used x).mp hx).2
    have hk'' : skeys[x]? = some k' := hjx ▸ hk'
    have e : k' = k := Option.some.inj (hk''.symm.trans hk)
    rw [e]
    exact hs
  · exact hu j hj' k' hk'

/-- Prior valid paths: a parent the old loop completed gets the identical
assignment from the replacement loop, whatever the provenance keys are. -/
theorem loop_ok_preserved (cs : List Tree) (skeys : List String) (pkeys : List Nat) :
    ∀ (fs : List (String × Nat)) (used perm : List Nat),
      UsedSingleton skeys used → loopOld skeys (fs.map Prod.fst) used = .ok perm →
      loopNew cs skeys pkeys fs used = .ok perm
  | [], _, _, _, h => h
  | (k, p) :: fs, used, perm, hu, h => by
    have h' : continueWith (uniqueOccurrence skeys k used)
        (fun j => loopOld skeys (fs.map Prod.fst) (j :: used)) = .ok perm := h
    obtain ⟨x, rest, hg, hrec, hperm⟩ := continueWith_ok _ _ perm h'
    have hc := unique_found skeys k used x hg
    have hs := singleton_of_unique skeys k used x hu hc
    have hn : provOccurrence cs skeys pkeys k p used = .found x := by
      rw [prov_singleton_class cs skeys pkeys k p used hs]
      exact hg
    have hu' := usedSingleton_cons skeys k used x hu hc hs
    have ih := loop_ok_preserved cs skeys pkeys fs (x :: used) rest hu' hrec
    rw [hperm]
    show continueWith (provOccurrence cs skeys pkeys k p used)
      (fun j => loopNew cs skeys pkeys fs (j :: used)) = .ok (x :: rest)
    rw [hn]
    exact congrArg (extend x) ih

/-- A parent the old loop refused as unsupported is still refused as
unsupported: the first failing child and its reason are unchanged. -/
theorem loop_unsupported_preserved (cs : List Tree) (skeys : List String) (pkeys : List Nat) :
    ∀ (fs : List (String × Nat)) (used : List Nat),
      UsedSingleton skeys used → loopOld skeys (fs.map Prod.fst) used = .unsupported →
      loopNew cs skeys pkeys fs used = .unsupported
  | [], _, _, h => by
    have h' : Outcome.ok ([] : List Nat) = Outcome.unsupported := h
    cases h'
  | (k, p) :: fs, used, hu, h => by
    have h' : continueWith (uniqueOccurrence skeys k used)
        (fun j => loopOld skeys (fs.map Prod.fst) (j :: used)) = .unsupported := h
    show continueWith (provOccurrence cs skeys pkeys k p used)
      (fun j => loopNew cs skeys pkeys fs (j :: used)) = .unsupported
    rcases continueWith_unsupported _ _ h' with hg | ⟨x, hg, hrec⟩
    · have e := (prov_unsupported_iff cs skeys pkeys k p used).mpr hg
      rw [e]
      rfl
    · have hc := unique_found skeys k used x hg
      have hs := singleton_of_unique skeys k used x hu hc
      have hn : provOccurrence cs skeys pkeys k p used = .found x := by
        rw [prov_singleton_class cs skeys pkeys k p used hs]
        exact hg
      have hu' := usedSingleton_cons skeys k used x hu hc hs
      have ih := loop_unsupported_preserved cs skeys pkeys fs (x :: used) hu' hrec
      rw [hn]
      exact congrArg (extend x) ih

/-- A certified child index that a key-preserving bridge may give to a fast
child with keys `(k, p)`: equal structural key, and equal provenance key when
the structural class is ambiguous. -/
def Admits (skeys : List String) (pkeys : List Nat) (k : String) (p : Nat) (r : Nat) : Prop :=
  skeys[r]? = some k ∧ (2 ≤ classSize skeys k → pkeys[r]? = some p)

/-- The admitted indices as a computed list (the class Java records). -/
def admitted (skeys : List String) (pkeys : List Nat) (k : String) (p : Nat) : List Nat :=
  (candidates skeys k []).filter fun r =>
    decide (classSize skeys k ≤ 1) || pkeys[r]? == some p

theorem mem_admitted (skeys : List String) (pkeys : List Nat) (k : String) (p : Nat) (r : Nat) :
    r ∈ admitted skeys pkeys k p ↔ Admits skeys pkeys k p r := by
  unfold admitted Admits
  rw [List.mem_filter, mem_candidates]
  constructor
  · intro ⟨⟨_, hk⟩, hp⟩
    refine ⟨hk, fun h2 => ?_⟩
    have hp' : classSize skeys k ≤ 1 ∨ pkeys[r]? = some p := by simpa using hp
    rcases hp' with h1 | h1
    · omega
    · exact h1
  · intro ⟨hk, hp⟩
    refine ⟨⟨by simp, hk⟩, ?_⟩
    by_cases hs : classSize skeys k ≤ 1
    · simp [hs]
    · have := hp (by omega)
      simp [this]

/-- Forced choice: when the admitted list is a singleton, it is the only
index any key-preserving bridge can take. -/
theorem forced_of_admitted_singleton (skeys : List String) (pkeys : List Nat) (k : String)
    (p : Nat) (x : Nat) (h : admitted skeys pkeys k p = [x]) :
    ∀ r, Admits skeys pkeys k p r → r = x := by
  intro r hr
  have hm := (mem_admitted skeys pkeys k p r).mpr hr
  rw [h] at hm
  simpa using hm

/-- Every used child is the same labelled subtree as every sibling admitted
under the same keys. -/
def UsedClosed (cs : List Tree) (skeys : List String) (pkeys : List Nat) (used : List Nat) : Prop :=
  ∀ j ∈ used, ∀ k p r, Admits skeys pkeys k p j → Admits skeys pkeys k p r → cs[r]? = cs[j]?

theorem usedClosed_nil (cs : List Tree) (skeys : List String) (pkeys : List Nat) :
    UsedClosed cs skeys pkeys [] := by
  intro j hj
  cases hj

theorem prov_step (cs : List Tree) (skeys : List String) (pkeys : List Nat) (k : String) (p : Nat)
    (used : List Nat) (x : Nat) (hu : UsedClosed cs skeys pkeys used)
    (h : provOccurrence cs skeys pkeys k p used = .found x) :
    Admits skeys pkeys k p x ∧ x ∉ used ∧
      (∀ r, Admits skeys pkeys k p r → cs[r]? = cs[x]?) ∧
      UsedClosed cs skeys pkeys (x :: used) := by
  obtain ⟨hmem, hpk⟩ := prov_found_mem cs skeys pkeys k p used x h
  obtain ⟨hnu, hsk⟩ := (mem_candidates skeys k used x).mp hmem
  have hadm : Admits skeys pkeys k p x := ⟨hsk, hpk⟩
  have hcl : ∀ r, Admits skeys pkeys k p r → cs[r]? = cs[x]? := by
    intro r hr
    by_cases hru : r ∈ used
    · exact (hu r hru k p x hr hadm).symm
    · have hrc : r ∈ candidates skeys k used := (mem_candidates skeys k used r).mpr ⟨hru, hr.1⟩
      rcases prov_choice_equal cs skeys pkeys k p used x h r hrc hr.2 with hrx | ⟨a, hxa, hra⟩
      · rw [hrx]
      · rw [hxa, hra]
  refine ⟨hadm, hnu, hcl, ?_⟩
  intro j hj k' p' r hjk hrk
  rcases List.mem_cons.mp hj with hjx | hj'
  · have hxk : Admits skeys pkeys k' p' x := hjx ▸ hjk
    have ek : k' = k := Option.some.inj (hxk.1.symm.trans hsk)
    have hr' : Admits skeys pkeys k p r := by
      refine ⟨ek ▸ hrk.1, fun h2 => ?_⟩
      have h2' : 2 ≤ classSize skeys k' := by rw [ek]; exact h2
      have ep : p' = p := Option.some.inj ((hxk.2 h2').symm.trans (hpk h2))
      rw [← ep]
      exact hrk.2 h2'
    rw [hjx]
    exact hcl r hr'
  · exact hu j hj' k' p' r hjk hrk

/-- A completed loop: each fast child got a certified child with its
structural key and, in an ambiguous class, its provenance key; and every
certified sibling admitted for that fast child is the same labelled subtree. -/
theorem loop_sound (cs : List Tree) (skeys : List String) (pkeys : List Nat) :
    ∀ (fs : List (String × Nat)) (used perm : List Nat),
      UsedClosed cs skeys pkeys used → loopNew cs skeys pkeys fs used = .ok perm →
      perm.length = fs.length ∧
      ∀ (t : Nat) (k : String) (p x : Nat), fs[t]? = some (k, p) → perm[t]? = some x →
        Admits skeys pkeys k p x ∧ x ∉ used ∧ ∀ r, Admits skeys pkeys k p r → cs[r]? = cs[x]?
  | [], _, perm, _, h => by
    have h' : Outcome.ok ([] : List Nat) = Outcome.ok perm := h
    cases h'
    exact ⟨rfl, fun t k p x hf _ => by simp at hf⟩
  | (k0, p0) :: fs, used, perm, hu, h => by
    have h' : continueWith (provOccurrence cs skeys pkeys k0 p0 used)
        (fun j => loopNew cs skeys pkeys fs (j :: used)) = .ok perm := h
    obtain ⟨x0, rest, hg, hrec, hperm⟩ := continueWith_ok _ _ perm h'
    obtain ⟨ha, hnu, hcl, hu'⟩ := prov_step cs skeys pkeys k0 p0 used x0 hu hg
    obtain ⟨ihl, iht⟩ := loop_sound cs skeys pkeys fs (x0 :: used) rest hu' hrec
    rw [hperm]
    refine ⟨by simp [ihl], ?_⟩
    intro t k p x hf hp
    cases t with
    | zero =>
      have e1 : k0 = k ∧ p0 = p := by simpa using hf
      have e2 : x0 = x := by simpa using hp
      rw [← e1.1, ← e1.2, ← e2]
      exact ⟨ha, hnu, hcl⟩
    | succ t =>
      have hf' : fs[t]? = some (k, p) := by simpa using hf
      have hp' : rest[t]? = some x := by simpa using hp
      obtain ⟨a1, a2, a3⟩ := iht t k p x hf' hp'
      exact ⟨a1, fun hx => a2 (List.mem_cons_of_mem _ hx), a3⟩

/-- Injectivity: no certified child is given to two fast children. -/
theorem loop_injective (cs : List Tree) (skeys : List String) (pkeys : List Nat) :
    ∀ (fs : List (String × Nat)) (used perm : List Nat),
      loopNew cs skeys pkeys fs used = .ok perm → (∀ x ∈ perm, x ∉ used) ∧ perm.Nodup
  | [], _, perm, h => by
    have h' : Outcome.ok ([] : List Nat) = Outcome.ok perm := h
    cases h'
    exact ⟨fun x hx => (by cases hx), List.nodup_nil⟩
  | (k0, p0) :: fs, used, perm, h => by
    have h' : continueWith (provOccurrence cs skeys pkeys k0 p0 used)
        (fun j => loopNew cs skeys pkeys fs (j :: used)) = .ok perm := h
    obtain ⟨x0, rest, hg, hrec, hperm⟩ := continueWith_ok _ _ perm h'
    have hx0 : x0 ∉ used :=
      ((mem_candidates skeys k0 used x0).mp (prov_found_mem cs skeys pkeys k0 p0 used x0 hg).1).1
    obtain ⟨ih1, ih2⟩ := loop_injective cs skeys pkeys fs (x0 :: used) rest hrec
    rw [hperm]
    refine ⟨?_, List.nodup_cons.mpr ⟨fun hin => ih1 x0 hin (List.mem_cons_self ..), ih2⟩⟩
    intro x hx
    rcases List.mem_cons.mp hx with hxx | hx'
    · rw [hxx]; exact hx0
    · exact fun hu => ih1 x hx' (List.mem_cons_of_mem _ hu)

/-- Coverage: with as many fast children as certified children, a completed
loop from the empty used set gives every certified child to some fast child. -/
theorem loop_covers (cs : List Tree) (skeys : List String) (pkeys : List Nat)
    (fs : List (String × Nat)) (perm : List Nat)
    (h : loopNew cs skeys pkeys fs [] = .ok perm) (hlen : fs.length = skeys.length) :
    ∀ j, j < skeys.length → j ∈ perm := by
  obtain ⟨hl, hfacts⟩ := loop_sound cs skeys pkeys fs [] perm (usedClosed_nil cs skeys pkeys) h
  obtain ⟨_, hnd⟩ := loop_injective cs skeys pkeys fs [] perm h
  apply nodup_bounded_covers skeys.length perm hnd (by rw [hl, hlen])
  intro x hx
  obtain ⟨t, ht⟩ := List.getElem?_of_mem hx
  have htl : t < fs.length := by rw [← hl]; exact lt_of_getElem? perm t x ht
  have hft : fs[t]? = some fs[t] := List.getElem?_eq_getElem htl
  obtain ⟨a1, _, _⟩ := hfacts t fs[t].1 fs[t].2 x hft ht
  exact lt_of_getElem? skeys x _ a1.1

/-! ### The whole endpoint bridge -/

/-- Key functions on subtrees: structural and provenance keys of fast and of
certified subtrees. Arbitrary functions; no injectivity is assumed. -/
structure Keys where
  fastS : Tree → String
  fastP : Tree → Nat
  certS : Tree → String
  certP : Tree → Nat

/-- A bridge is given by one assignment row per fast occurrence. -/
def step (m : Path → List Nat) (q : Path) (i : Nat) : Nat := ((m q)[i]?).getD i

/-- Certified occurrence of the fast occurrence `pre ++ q`, relative to `pre`. -/
def image (m : Path → List Nat) : Path → Path → Path
  | _, [] => []
  | pre, i :: rest => step m pre i :: image m (pre ++ [i]) rest

theorem image_snoc (m : Path → List Nat) : ∀ (q pre : Path) (i : Nat),
    image m pre (q ++ [i]) = image m pre q ++ [step m (pre ++ q) i]
  | [], pre, i => by simp [image]
  | a :: q, pre, i => by
    have ih := image_snoc m q (pre ++ [a]) i
    simp only [List.cons_append, image, ih, List.append_assoc, List.nil_append]

theorem image_snoc_root (m : Path → List Nat) (q : Path) (i : Nat) :
    image m [] (q ++ [i]) = image m [] q ++ [step m q i] := by
  rw [image_snoc]
  simp

theorem snoc_induction {α : Type} {P : List α → Prop} (hnil : P [])
    (hsnoc : ∀ l a, P l → P (l ++ [a])) (l : List α) : P l := by
  have h : ∀ r : List α, P r.reverse := by
    intro r
    induction r with
    | nil => exact hnil
    | cons a r ih =>
      rw [List.reverse_cons]
      exact hsnoc _ _ ih
  have h' := h l.reverse
  rwa [List.reverse_reverse] at h'

theorem occurrence_snoc (t : Tree) (q : Path) (i : Nat) (h : (get? (q ++ [i]) t).isSome) :
    ∃ fn fc, get? q t = some fn ∧ (children fn)[i]? = some fc := by
  rw [get_append] at h
  cases hf : get? q t with
  | none => rw [hf] at h; simp at h
  | some fn =>
    rw [hf] at h
    have h' : ((children fn)[i]?).isSome := by
      rw [← get_child]
      exact h
    cases hc : (children fn)[i]? with
    | none => rw [hc] at h'; simp at h'
    | some fc => exact ⟨fn, fc, rfl, hc⟩

theorem occurrence_prefix (t : Tree) (p rest : Path) (h : (get? (p ++ rest) t).isSome) :
    (get? p t).isSome := by
  rw [get_append] at h
  cases hp : get? p t with
  | none => rw [hp] at h; simp at h
  | some _ => rfl

/-- `x` is a certified child index a key-preserving bridge may give to the
fast child `f` under the parent with certified children `cs`. -/
def AdmitsChild (K : Keys) (cs : List Tree) (f : Tree) (x : Nat) : Prop :=
  Admits (cs.map K.certS) (cs.map K.certP) (K.fastS f) (K.fastP f) x

/-- Key-preserving bridge: an ordered parent keeps child indices; an unordered
parent gives each fast child a certified child admitted for its keys. -/
def KeyPreserving (K : Keys) (F C : Tree) (m : Path → List Nat) : Prop :=
  ∀ q i fn fc l cs, get? q F = some fn → (children fn)[i]? = some fc →
    get? (image m [] q) C = some (.node l cs) →
    (l.unordered = false → step m q i = i) ∧
    (l.unordered = true → AdmitsChild K cs fc (step m q i))

/-- Twin closure: every certified sibling admitted for a fast child is the
same labelled subtree as the chosen one. -/
def TwinClosed (K : Keys) (F C : Tree) (m : Path → List Nat) : Prop :=
  ∀ q i fn fc l cs, get? q F = some fn → (children fn)[i]? = some fc →
    get? (image m [] q) C = some (.node l cs) → l.unordered = true →
    ∀ r, AdmitsChild K cs fc r → cs[r]? = cs[step m q i]?

/-- The chosen child for fast child `i` of the fast node at `q` is the only
admitted certified sibling. -/
def ForcedAt (K : Keys) (F C : Tree) (m : Path → List Nat) (q : Path) (i : Nat) : Prop :=
  ∀ fn fc l cs, get? q F = some fn → (children fn)[i]? = some fc →
    get? (image m [] q) C = some (.node l cs) → l.unordered = true →
    ∀ r, AdmitsChild K cs fc r → r = step m q i

/-- Every choice on the way to the fast occurrence `q` was forced. -/
def ForcedPath (K : Keys) (F C : Tree) (m : Path → List Nat) (q : Path) : Prop :=
  ∀ q' i rest, q = q' ++ i :: rest → ForcedAt K F C m q' i

def Lands (F C : Tree) (m : Path → List Nat) : Prop :=
  ∀ q, (get? q F).isSome → (get? (image m [] q) C).isSome

/-- Any key-preserving alternative reads the same labelled subtree as a
twin-closed bridge at every fast occurrence. No exchange decomposition, no
bound on the number of differing choices. -/
theorem bridge_reads_agree (K : Keys) (F C : Tree) (m m' : Path → List Nat)
    (hm : KeyPreserving K F C m) (hm' : KeyPreserving K F C m') (hc : TwinClosed K F C m)
    (q : Path) : (get? q F).isSome → get? (image m [] q) C = get? (image m' [] q) C := by
  induction q using snoc_induction with
  | hnil => intro _; rfl
  | hsnoc q i ih =>
    intro hq
    obtain ⟨fn, fc, hf, hfc⟩ := occurrence_snoc F q i hq
    have ih' := ih (by simp [hf])
    rw [image_snoc_root, image_snoc_root, get_append, get_append, ← ih']
    cases hcn : get? (image m [] q) C with
    | none => rfl
    | some cn =>
      cases cn with
      | node l cs =>
        have h1 := hm q i fn fc l cs hf hfc hcn
        have h2 := hm' q i fn fc l cs hf hfc (by rw [← ih']; exact hcn)
        show get? [step m q i] (.node l cs) = get? [step m' q i] (.node l cs)
        rw [get_child, get_child]
        show cs[step m q i]? = cs[step m' q i]?
        cases hu : l.unordered with
        | false => rw [h1.1 hu, h2.1 hu]
        | true => exact (hc q i fn fc l cs hf hfc hcn hu (step m' q i) (h2.2 hu)).symm

/-- On an occurrence whose ancestors' choices were all forced, every
key-preserving alternative coincides with the chosen bridge. -/
theorem bridge_forced_unique (K : Keys) (F C : Tree) (m m' : Path → List Nat)
    (hl : Lands F C m) (hm : KeyPreserving K F C m) (hm' : KeyPreserving K F C m')
    (q : Path) :
    (get? q F).isSome → ForcedPath K F C m q → image m' [] q = image m [] q := by
  induction q using snoc_induction with
  | hnil => intro _ _; rfl
  | hsnoc q i ih =>
    intro hq hforced
    obtain ⟨fn, fc, hf, hfc⟩ := occurrence_snoc F q i hq
    have hqs : (get? q F).isSome := by simp [hf]
    have ih' := ih hqs (fun q' i' rest e => hforced q' i' (rest ++ [i]) (by rw [e]; simp))
    have hstep : step m' q i = step m q i := by
      have hls := hl q hqs
      cases hcn : get? (image m [] q) C with
      | none => rw [hcn] at hls; simp at hls
      | some cn =>
        cases cn with
        | node l cs =>
          have h1 := hm q i fn fc l cs hf hfc hcn
          have h2 := hm' q i fn fc l cs hf hfc (by rw [ih']; exact hcn)
          cases hu : l.unordered with
          | false => rw [h1.1 hu, h2.1 hu]
          | true => exact hforced q i [] rfl fn fc l cs hf hfc hcn hu (step m' q i) (h2.2 hu)
    rw [image_snoc_root, image_snoc_root, ih', hstep]

/-- Fast children's keys in child order. -/
def fastKeys (K : Keys) (fn : Tree) : List (String × Nat) :=
  (children fn).map fun f => (K.fastS f, K.fastP f)

/-- The bridge built by the gate: at every corresponded pair the child counts
agree, an ordered parent keeps indices and an unordered parent's row is the
completed loop from the empty used set. -/
def GateBuilt (K : Keys) (F C : Tree) (m : Path → List Nat) : Prop :=
  ∀ q fn l cs, get? q F = some fn → get? (image m [] q) C = some (.node l cs) →
    (children fn).length = cs.length ∧
    (l.unordered = false → ∀ i, step m q i = i) ∧
    (l.unordered = true →
      loopNew cs (cs.map K.certS) (cs.map K.certP) (fastKeys K fn) [] = .ok (m q))

theorem gate_row (K : Keys) (fn : Tree) (cs : List Tree) (row : List Nat)
    (h : loopNew cs (cs.map K.certS) (cs.map K.certP) (fastKeys K fn) [] = .ok row)
    (i : Nat) (fc : Tree) (hfc : (children fn)[i]? = some fc) :
    ∃ x, row[i]? = some x ∧ AdmitsChild K cs fc x ∧
      ∀ r, AdmitsChild K cs fc r → cs[r]? = cs[x]? := by
  obtain ⟨hlen, hfacts⟩ := loop_sound cs (cs.map K.certS) (cs.map K.certP) (fastKeys K fn) [] row
    (usedClosed_nil cs (cs.map K.certS) (cs.map K.certP)) h
  have hi : i < row.length := by
    rw [hlen]
    unfold fastKeys
    rw [List.length_map]
    exact lt_of_getElem? _ i fc hfc
  have hrow : row[i]? = some row[i] := List.getElem?_eq_getElem hi
  have hfs : (fastKeys K fn)[i]? = some (K.fastS fc, K.fastP fc) := by
    unfold fastKeys
    simp [hfc]
  obtain ⟨a1, _, a3⟩ := hfacts i (K.fastS fc) (K.fastP fc) row[i] hfs hrow
  exact ⟨row[i], hrow, a1, a3⟩

theorem step_of_row (m : Path → List Nat) (q : Path) (i x : Nat) (h : (m q)[i]? = some x) :
    step m q i = x := by
  simp [step, h]

theorem gateBuilt_keyPreserving (K : Keys) (F C : Tree) (m : Path → List Nat)
    (g : GateBuilt K F C m) : KeyPreserving K F C m := by
  intro q i fn fc l cs hf hfc hcn
  obtain ⟨_, hord, hun⟩ := g q fn l cs hf hcn
  refine ⟨fun hu => hord hu i, fun hu => ?_⟩
  obtain ⟨x, hx, ha, _⟩ := gate_row K fn cs (m q) (hun hu) i fc hfc
  rw [step_of_row m q i x hx]
  exact ha

theorem gateBuilt_twinClosed (K : Keys) (F C : Tree) (m : Path → List Nat)
    (g : GateBuilt K F C m) : TwinClosed K F C m := by
  intro q i fn fc l cs hf hfc hcn hu r hr
  obtain ⟨_, _, hun⟩ := g q fn l cs hf hcn
  obtain ⟨x, hx, _, hcl⟩ := gate_row K fn cs (m q) (hun hu) i fc hfc
  rw [step_of_row m q i x hx]
  exact hcl r hr

theorem gateBuilt_lands (K : Keys) (F C : Tree) (m : Path → List Nat) (g : GateBuilt K F C m)
    (q : Path) : (get? q F).isSome → (get? (image m [] q) C).isSome := by
  induction q using snoc_induction with
  | hnil => intro _; rfl
  | hsnoc q i ih =>
    intro hq
    obtain ⟨fn, fc, hf, hfc⟩ := occurrence_snoc F q i hq
    have ihs := ih (by simp [hf])
    rw [image_snoc_root, get_append]
    cases hcn : get? (image m [] q) C with
    | none => rw [hcn] at ihs; simp at ihs
    | some cn =>
      cases cn with
      | node l cs =>
        obtain ⟨hlen, hord, hun⟩ := g q fn l cs hf hcn
        show (get? [step m q i] (.node l cs)).isSome
        rw [get_child]
        show (cs[step m q i]?).isSome
        have hi : i < cs.length := by
          rw [← hlen]
          exact lt_of_getElem? _ i fc hfc
        cases hu : l.unordered with
        | false =>
          rw [hord hu i]
          simp [hi]
        | true =>
          obtain ⟨x, hx, ha, _⟩ := gate_row K fn cs (m q) (hun hu) i fc hfc
          rw [step_of_row m q i x hx]
          have hxlt : x < cs.length := by
            have := lt_of_getElem? _ x _ ha.1
            simpa using this
          simp [hxlt]

theorem gate_bridge_injective_aux (K : Keys) (F C : Tree) (m : Path → List Nat)
    (g : GateBuilt K F C m) :
    ∀ (q q' pre : Path), (get? (pre ++ q) F).isSome → (get? (pre ++ q') F).isSome →
      image m pre q = image m pre q' → q = q'
  | [], [], _, _, _, _ => rfl
  | [], _ :: _, _, _, _, h => by simp [image] at h
  | _ :: _, [], _, _, _, h => by simp [image] at h
  | i :: rest, i' :: rest', pre, hq, hq', h => by
    simp only [image, List.cons.injEq] at h
    obtain ⟨hstep, htail⟩ := h
    have hq1 : (get? ((pre ++ [i]) ++ rest) F).isSome := by simpa using hq
    have hq1' : (get? ((pre ++ [i']) ++ rest') F).isSome := by simpa using hq'
    obtain ⟨fn, fc, hf, hfc⟩ := occurrence_snoc F pre i (occurrence_prefix F _ rest hq1)
    obtain ⟨fn', fc', hf', hfc'⟩ := occurrence_snoc F pre i' (occurrence_prefix F _ rest' hq1')
    have efn : fn' = fn := Option.some.inj (hf'.symm.trans hf)
    rw [efn] at hfc'
    have hls := gateBuilt_lands K F C m g pre (by simp [hf])
    have hi : i = i' := by
      cases hcn : get? (image m [] pre) C with
      | none => rw [hcn] at hls; simp at hls
      | some cn =>
        cases cn with
        | node l cs =>
          obtain ⟨_, hord, hun⟩ := g pre fn l cs hf hcn
          cases hu : l.unordered with
          | false =>
            rw [hord hu i, hord hu i'] at hstep
            exact hstep
          | true =>
            obtain ⟨x, hx, _, _⟩ := gate_row K fn cs (m pre) (hun hu) i fc hfc
            obtain ⟨x', hx', _, _⟩ := gate_row K fn cs (m pre) (hun hu) i' fc' hfc'
            rw [step_of_row m pre i x hx, step_of_row m pre i' x' hx'] at hstep
            rw [← hstep] at hx'
            exact nodup_index_inj (m pre) i i' x
              (loop_injective cs _ _ _ [] (m pre) (hun hu)).2 hx hx'
    rw [← hi] at htail hq1'
    rw [gate_bridge_injective_aux K F C m g rest rest' (pre ++ [i]) hq1 hq1' htail, hi]

/-- Injectivity of the built bridge on fast occurrences. -/
theorem gate_bridge_injective (K : Keys) (F C : Tree) (m : Path → List Nat)
    (g : GateBuilt K F C m) (q q' : Path) (hq : (get? q F).isSome) (hq' : (get? q' F).isSome)
    (h : image m [] q = image m [] q') : q = q' :=
  gate_bridge_injective_aux K F C m g q q' [] (by simpa using hq) (by simpa using hq') h

/-- Coverage of the built bridge: every certified occurrence is the image of a
fast occurrence. -/
theorem gate_bridge_covers (K : Keys) (F C : Tree) (m : Path → List Nat) (g : GateBuilt K F C m)
    (r : Path) : (get? r C).isSome → ∃ q, (get? q F).isSome ∧ image m [] q = r := by
  induction r using snoc_induction with
  | hnil => intro _; exact ⟨[], rfl, rfl⟩
  | hsnoc r j ih =>
    intro hr
    obtain ⟨cn, cc, hcn, hcc⟩ := occurrence_snoc C r j hr
    obtain ⟨q, hq, himg⟩ := ih (by simp [hcn])
    cases hf : get? q F with
    | none => rw [hf] at hq; simp at hq
    | some fn =>
      cases cn with
      | node l cs =>
        have hcn' : get? (image m [] q) C = some (.node l cs) := by rw [himg]; exact hcn
        obtain ⟨hlen, hord, hun⟩ := g q fn l cs hf hcn'
        have hj : j < cs.length := lt_of_getElem? cs j cc hcc
        have hex : ∃ i, i < (children fn).length ∧ step m q i = j := by
          cases hu : l.unordered with
          | false => exact ⟨j, by rw [hlen]; exact hj, hord hu j⟩
          | true =>
            have hloop := hun hu
            have hfl : (fastKeys K fn).length = (cs.map K.certS).length := by
              unfold fastKeys
              simp [hlen]
            have hcov := loop_covers cs (cs.map K.certS) (cs.map K.certP) (fastKeys K fn) (m q)
              hloop hfl j (by simpa using hj)
            obtain ⟨i, hi⟩ := List.getElem?_of_mem hcov
            have hrl := (loop_sound cs (cs.map K.certS) (cs.map K.certP) (fastKeys K fn) [] (m q)
              (usedClosed_nil cs (cs.map K.certS) (cs.map K.certP)) hloop).1
            refine ⟨i, ?_, step_of_row m q i j hi⟩
            have hil := lt_of_getElem? (m q) i j hi
            rw [hrl] at hil
            unfold fastKeys at hil
            simpa using hil
        obtain ⟨i, hi, hs⟩ := hex
        refine ⟨q ++ [i], ?_, ?_⟩
        · rw [get_append, hf]
          show (get? [i] fn).isSome
          rw [get_child]
          simp [hi]
        · rw [image_snoc_root, himg, hs]

/-! ### Verdicts under the built bridges -/

/-- All coordinates of a fast-arm action are occurrences of the fast endpoints. -/
def WellPlaced (FL FR : Tree) (a : Action) : Prop :=
  (∀ q, a.source = some q → (get? q FL).isSome) ∧ (∀ q, a.target = some q → (get? q FR).isSome)

/-- Every choice on the way to each coordinate of the action was forced. -/
def ForcedCoordinates (KL KR : Keys) (FL CL FR CR : Tree) (mL mR : Path → List Nat)
    (a : Action) : Prop :=
  (∀ q, a.source = some q → ForcedPath KL FL CL mL q) ∧
  (∀ q, a.target = some q → ForcedPath KR FR CR mR q)

/-- MATCHED soundness. If the fast-arm actions, bridged by the gate-built
bridges of the left and right endpoints, are literally the certified actions,
then under every key-preserving alternative pair of bridges the bridged actions
resolve, in order, to the same kinds, charges and labelled subtrees as the
certified actions. -/
theorem gate_matched_sound (KL KR : Keys) (FL CL FR CR : Tree) (mL mR mL' mR' : Path → List Nat)
    (gL : GateBuilt KL FL CL mL) (gR : GateBuilt KR FR CR mR)
    (hL' : KeyPreserving KL FL CL mL') (hR' : KeyPreserving KR FR CR mR')
    (acts certified : List Action) (hw : ∀ a ∈ acts, WellPlaced FL FR a)
    (h : acts.map (mapBoth (image mL []) (image mR [])) = certified) :
    (acts.map (mapBoth (image mL' []) (image mR' []))).map (resolve CL CR) =
      certified.map (resolve CL CR) := by
  rw [← h]
  exact (resolve_list_congr CL CR (image mL []) (image mL' []) (image mR []) (image mR' []) acts
    (fun a ha q hq => bridge_reads_agree KL FL CL mL mL' (gateBuilt_keyPreserving KL FL CL mL gL)
      hL' (gateBuilt_twinClosed KL FL CL mL gL) q ((hw a ha).1 q hq))
    (fun a ha q hq => bridge_reads_agree KR FR CR mR mR' (gateBuilt_keyPreserving KR FR CR mR gR)
      hR' (gateBuilt_twinClosed KR FR CR mR gR) q ((hw a ha).2 q hq))).symm

/-- Verdict independence. When every choice on the way to every action
coordinate was forced, every key-preserving alternative pair of bridges yields
literally the same bridged list, hence the same ordered verdict. -/
theorem gate_verdict_independent (KL KR : Keys) (FL CL FR CR : Tree)
    (mL mR mL' mR' : Path → List Nat)
    (gL : GateBuilt KL FL CL mL) (gR : GateBuilt KR FR CR mR)
    (hL' : KeyPreserving KL FL CL mL') (hR' : KeyPreserving KR FR CR mR')
    (acts certified : List Action) (hw : ∀ a ∈ acts, WellPlaced FL FR a)
    (hf : ∀ a ∈ acts, ForcedCoordinates KL KR FL CL FR CR mL mR a) :
    (acts.map (mapBoth (image mL' []) (image mR' [])) = certified) ↔
      (acts.map (mapBoth (image mL []) (image mR [])) = certified) := by
  have e : acts.map (mapBoth (image mL' []) (image mR' [])) =
      acts.map (mapBoth (image mL []) (image mR [])) :=
    mapBoth_list_congr (image mL' []) (image mL []) (image mR' []) (image mR []) acts
      (fun a ha q hq => bridge_forced_unique KL FL CL mL mL' (gateBuilt_lands KL FL CL mL gL)
        (gateBuilt_keyPreserving KL FL CL mL gL) hL' q ((hw a ha).1 q hq) ((hf a ha).1 q hq))
      (fun a ha q hq => bridge_forced_unique KR FR CR mR mR' (gateBuilt_lands KR FR CR mR gR)
        (gateBuilt_keyPreserving KR FR CR mR gR) hR' q ((hw a ha).2 q hq) ((hf a ha).2 q hq))
  rw [e]

end ACGN.FifthFive.RepeatedOccurrence
