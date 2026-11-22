import Std
import Std.Data.String.ToNat
import DecodedEvidenceCoverage

namespace ACGN.Eighth.P609

/-- A word contains UTF-16 code units as natural numbers. The argument below
holds for every payload, hence also for every Java String (including surrogates).
The decimal digits and punctuation occupy one code unit each. -/
abbrev Word := List Nat

def ascii (s : String) : Word := s.toList.map Char.toNat
def decimal (n : Nat) : Word := ascii n.repr
def header (n : Nat) : Word := decimal n ++ [58]
def field (payload : Word) : Word := header payload.length ++ payload
def fields (xs : List Word) : Word := xs.flatMap field

theorem splitDelimiter {a b x y : Word} (ha : 58 ∉ a) (hb : 58 ∉ b)
    (h : a ++ 58 :: x = b ++ 58 :: y) : a = b ∧ x = y := by
  induction a generalizing b with
  | nil =>
    cases b with
    | nil => exact ⟨rfl, (List.cons.inj h).2⟩
    | cons n rest =>
      have hn : 58 = n := (List.cons.inj h).1
      exact False.elim (hb (by simp [hn]))
  | cons n rest ih =>
    cases b with
    | nil =>
      have hn : n = 58 := (List.cons.inj h).1
      exact False.elim (ha (by simp [hn]))
    | cons m tail =>
      obtain ⟨rfl, tailEq⟩ := List.cons.inj h
      obtain ⟨rfl, finalEq⟩ := ih (fun hin => ha (by simp [hin]))
        (fun hin => hb (by simp [hin])) tailEq
      exact ⟨rfl, finalEq⟩

theorem noColon (n : Nat) : 58 ∉ decimal n := by
  intro h
  obtain ⟨c, hc, he⟩ := List.mem_map.mp h
  have hd := Nat.isDigit_of_mem_toDigits (by decide : 0 < 10) (by decide : 10 ≤ 10)
    (by simpa [Nat.toList_repr] using hc)
  have eq : c = ':' := Char.toNat_inj.mp he
  subst c
  contradiction

theorem decimal_inj {n m : Nat} (h : decimal n = decimal m) : n = m := by
  have lists : n.repr.toList = m.repr.toList := by
    have := congrArg (List.map Char.ofNat) h
    simpa [decimal, ascii, List.map_map, Function.comp_def] using this
  exact Nat.repr_injective (String.toList_inj.mp lists)

theorem header_separates {n m : Nat} {x y : Word}
    (h : header n ++ x = header m ++ y) : n = m ∧ x = y := by
  obtain ⟨h₁,h₂⟩ := splitDelimiter (noColon n) (noColon m)
    (by simpa [header, List.append_assoc] using h)
  exact ⟨decimal_inj h₁,h₂⟩

theorem field_separates {a b x y : Word} (h : field a ++ x = field b ++ y) :
    a = b ∧ x = y := by
  obtain ⟨len, tailEq⟩ := header_separates (by simpa [field, List.append_assoc] using h)
  have both := congrArg (List.take a.length) tailEq
  have ab : a = b := by simpa [len] using both
  exact ⟨ab, List.append_cancel_left (ab ▸ tailEq)⟩

theorem fields_separate {a b : List Word} {x y : Word} (len : a.length = b.length)
    (h : fields a ++ x = fields b ++ y) : a = b ∧ x = y := by
  induction a generalizing b with
  | nil =>
    obtain rfl : b = [] := List.length_eq_zero_iff.mp len.symm
    exact ⟨rfl,h⟩
  | cons v vs ih =>
    cases b with
    | nil => simp at len
    | cons w ws =>
      obtain ⟨rfl,tailEq⟩ := field_separates (by simpa [fields, List.append_assoc] using h)
      obtain ⟨rfl,xy⟩ := ih (by simpa using len) tailEq
      exact ⟨rfl,xy⟩

/-- One actual StructuralKey frame, with recursively encoded child words.
This is decimal length framing, including child lengths, not a digest. -/
structure Node where
  tag : Word
  scalars : List Word
  children : List Word

def render (k : Node) : Word :=
  field k.tag ++ [91] ++ header k.scalars.length ++ fields k.scalars ++ [93,123] ++
    header k.children.length ++ fields k.children ++ [125]

theorem render_injective {a b : Node} (h : render a = render b) : a = b := by
  obtain ⟨ht,hr⟩ := field_separates (by simpa [render, List.append_assoc] using h)
  obtain ⟨hs,hr⟩ := header_separates (List.cons.inj hr).2
  obtain ⟨hv,hr⟩ := fields_separate hs hr
  obtain ⟨hc,hr⟩ := header_separates (List.cons.inj (List.cons.inj hr).2).2
  obtain ⟨hw,_⟩ := fields_separate hc hr
  cases a; cases b; simp_all

/- Structural keys may contain arbitrary finite nested child keys. Separate
lists let the proof recurse on the exact subkeys after splitting their frames. -/
mutual
  inductive Key where
    | node (tag : Word) (scalars : List Word) (children : Children)
  inductive Children where
    | nil
    | cons (head : Key) (tail : Children)
end

mutual
  def encodeKey : Key → Word
    | .node tag scalars children => render ⟨tag, scalars, encodeChildren children⟩
  def encodeChildren : Children → List Word
    | .nil => []
    | .cons head tail => encodeKey head :: encodeChildren tail
end

mutual
  theorem nested_keys_injective (x y : Key) (eq : encodeKey x = encodeKey y) :
      x = y := by
    cases x with
    | node t s c =>
      cases y with
      | node t' s' c' =>
        obtain ⟨rfl, rfl, hc⟩ := Node.mk.inj (render_injective eq)
        rw [nested_children_injective c c' hc]
  theorem nested_children_injective (xs ys : Children) (eq : encodeChildren xs = encodeChildren ys) :
      xs = ys := by
    cases xs with
    | nil => cases ys <;> simp_all [encodeChildren]
    | cons x rest =>
      cases ys with
      | nil => simp [encodeChildren] at eq
      | cons y tail =>
        obtain ⟨hk, hr⟩ := List.cons.inj eq
        rw [nested_keys_injective x y hk, nested_children_injective rest tail hr]
end

/-- Distinct verification data; each nested field is already its canonical key.
The thirteen positions follow TypedEqualityCertificate and its binder subclass. -/
structure Occurrence where
  left : Word
  right : Word
  typeCheck : Word
  root : Word
  descriptor : Word
  context : Word
  occurrenceMap : Word
  automorphism : Word
  conjugate : Word
  path : List Nat
  source : Word
  target : Word
  premise : Word

def pathKey (p : List Nat) : Word :=
  render ⟨ascii "binder-occurrence-source-path-v1", p.map decimal, []⟩

def identityKey (o : Occurrence) : Word :=
  render ⟨ascii "typed-equality-certificate", [ascii "BINDER_AUTOMORPHISM"],
    [o.left, o.right, o.typeCheck, o.root, o.descriptor, o.context, o.occurrenceMap,
      o.automorphism, o.conjugate, pathKey o.path, o.source, o.target,
      render ⟨ascii "certificate-premise", [], [o.premise]⟩]⟩

theorem path_injective {a b : List Nat} (h : pathKey a = pathKey b) : a = b := by
  have he := congrArg Node.scalars (render_injective h)
  change a.map decimal = b.map decimal at he
  clear h
  induction a generalizing b with
  | nil => cases b <;> simp_all
  | cons n ns ih =>
    cases b with
    | nil => simp at he
    | cons m ms =>
      obtain ⟨hd, ht⟩ := List.cons.inj he
      rw [decimal_inj hd, ih ht]

theorem identity_injective {a b : Occurrence} (h : identityKey a = identityKey b) : a = b := by
  have he := congrArg Node.children (render_injective h)
  simp only [List.cons.injEq, and_true] at he
  obtain ⟨l, r, t, rt, d, c, o, am, cg, p, s, tg, pr⟩ := he
  have hp := path_injective p
  have prem := congrArg Node.children (render_injective pr)
  cases a; cases b; simp_all

open ACGN.Sixth.EvidenceCoverage

/-- An orbit consumer checks the raw local root/source IDs and path as well as the
key derived for that descriptor generator. Equal framed keys alone cannot transfer ownership. -/
def resolved (root : Nat) (path : List Nat) (t : Term)
    (reconstruct : BinderNeed → Occurrence) (owner : BinderNeed) (claim : Occurrence) : Prop :=
  (owner, identityKey claim) ∈ (walk root path t).map (fun n => (n, identityKey (reconstruct n)))

theorem resolved_iff (root : Nat) (path : List Nat) (t : Term)
    (reconstruct : BinderNeed → Occurrence) (owner : BinderNeed) (claim : Occurrence) :
    resolved root path t reconstruct owner claim ↔
      At root (.term path t) owner ∧ reconstruct owner = claim := by
  constructor
  · intro member
    obtain ⟨n, valid, eq⟩ := List.mem_map.mp member
    obtain ⟨rfl, hk⟩ := Prod.mk.inj eq
    exact ⟨(walk_exact _ _ _ _).mp valid, identity_injective hk⟩
  · rintro ⟨valid, rfl⟩
    exact List.mem_map.mpr ⟨owner, (walk_exact _ _ _ _).mpr valid, rfl⟩

theorem no_dangling_empty_claim (root : Nat) (path : List Nat) (t : Term)
    (reconstruct : BinderNeed → Occurrence) (noNeed : walk root path t = [])
    (owner : BinderNeed) (claim : Occurrence) :
    ¬ resolved root path t reconstruct owner claim := by simp [resolved, noNeed]

theorem rootless_substitution_refused {a b : Occurrence} (h : a.root ≠ b.root) :
    identityKey a ≠ identityKey b := fun eq => h (congrArg Occurrence.root (identity_injective eq))

#print axioms splitDelimiter
#print axioms noColon
#print axioms decimal_inj
#print axioms header_separates
#print axioms field_separates
#print axioms fields_separate
#print axioms render_injective
#print axioms nested_keys_injective
#print axioms nested_children_injective
#print axioms path_injective
#print axioms identity_injective
#print axioms rootless_substitution_refused
#print axioms resolved_iff
#print axioms no_dangling_empty_claim

end ACGN.Eighth.P609
