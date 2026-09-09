import Std

namespace ACGN.FifthFive.CanonicalWireTables

abbrev Bytes := List Nat

inductive Node where
  | mk (tag : Bytes) (scalars : List Bytes) (children : List Node)
  deriving BEq

def Node.tag : Node -> Bytes | .mk t _ _ => t
def Node.scalars : Node -> List Bytes | .mk _ s _ => s
def Node.children : Node -> List Node | .mk _ _ c => c

def u32 (n : Nat) : Bytes :=
  [n / 16777216 % 256, n / 65536 % 256, n / 256 % 256, n % 256]

def frame (s : Bytes) : Bytes := u32 s.length ++ s

mutual
def encode : Node -> Bytes
  | .mk t s c => frame t ++ u32 s.length ++ s.flatMap frame ++
      u32 c.length ++ encodeForest c

def encodeForest : List Node -> Bytes
  | [] => []
  | n :: ns => encode n ++ encodeForest ns
end

def continuation (n : Nat) : Bool := 128 <= n && n <= 191

-- Reject overlong sequences, surrogates, out-of-range scalars, and truncation.
def utf8 : Bytes -> Bool
  | [] => true
  | a :: xs =>
    if a < 128 then utf8 xs else
    match xs with
    | b :: rest =>
      if 194 <= a && a <= 223 then continuation b && utf8 rest else
      match rest with
      | c :: tail =>
        if 224 <= a && a <= 239 then
          continuation b && continuation c && (a != 224 || b >= 160) &&
            (a != 237 || b < 160) && utf8 tail
        else match tail with
        | d :: more =>
          240 <= a && a <= 244 && continuation b && continuation c && continuation d &&
            (a != 240 || b >= 144) && (a != 244 || b < 144) && utf8 more
        | [] => false
      | [] => false
    | [] => false

mutual
def grammar : Node -> Bool
  | .mk t s c => !t.isEmpty && utf8 t && t.length < 2147483648 &&
      s.length < 2147483648 && c.length < 2147483648 &&
      s.all (fun x => utf8 x && x.length < 2147483648) &&
      grammarForest c

def grammarForest : List Node -> Bool
  | [] => true
  | n :: ns => grammar n && grammarForest ns
end

def read32 : Bytes -> Option (Nat × Bytes)
  | a :: b :: c :: d :: rest =>
    if a < 128 && b < 256 && c < 256 && d < 256 then
      some (a * 16777216 + b * 65536 + c * 256 + d, rest) else none
  | _ => none

def readText (input : Bytes) : Option (Bytes × Bytes) := do
  let (n, rest) <- read32 input
  if n <= rest.length && utf8 (rest.take n) then some (rest.take n, rest.drop n) else none

def readMany (parse : Bytes -> Option (α × Bytes)) : Nat -> Bytes -> Option (List α × Bytes)
  | 0, input => some ([], input)
  | n + 1, input => do
    let (x, rest) <- parse input
    let (xs, tail) <- readMany parse n rest
    return (x :: xs, tail)

-- Fuel is an explicit caller-supplied tree-depth bound, not hidden partiality.
def parse : Nat -> Bytes -> Option (Node × Bytes)
  | 0, _ => none
  | fuel + 1, input => do
    let (t, rest) <- readText input
    if t.isEmpty then none else do
      let (ns, rest) <- read32 rest
      if ns > rest.length then none else do
        let (s, rest) <- readMany readText ns rest
        let (nc, rest) <- read32 rest
        if nc > rest.length then none else do
          let (c, rest) <- readMany (parse fuel) nc rest
          return (.mk t s c, rest)

def decode (fuel : Nat) (input : Bytes) : Option Node :=
  match parse fuel input with
  | none => none
  | some (n, rest) =>
    if rest.isEmpty && grammar n && encode n == input then some n else none

-- The content-ID preimage is the *node encoding*, without the file envelope.
def content (n : Node) : Node :=
  .mk (n.tag ++ [47, 99, 111, 110, 116, 101, 110, 116]) n.scalars.tail n.children

def preimage (n : Node) : Bytes := encode (content n)
def recordId (n : Node) : Bytes := n.scalars.headD []
def identified (hash : Bytes -> Bytes) (t : Bytes) (s : List Bytes) (c : List Node) : Node :=
  let body := Node.mk t ([] :: s) c
  .mk t (hash (preimage body) :: s) c

def lexLT : Bytes -> Bytes -> Bool
  | [], [] => false
  | [], _ :: _ => true
  | _ :: _, [] => false
  | a :: xs, b :: ys => if a == b then lexLT xs ys else a < b

-- Input is always UTF-8 wire bytes; only the comparator uses UTF-16 units.
-- Malformed input is outside this conversion's contract (grammar rejects it).
def utf16Units : Bytes -> List Nat
  | [] => []
  | a :: xs =>
    if a < 128 then a :: utf16Units xs else
    match xs with
    | b :: rest =>
      if a < 224 then ((a - 192) * 64 + b - 128) :: utf16Units rest else
      match rest with
      | c :: tail =>
        if a < 240 then ((a - 224) * 4096 + (b - 128) * 64 + c - 128) :: utf16Units tail else
        match tail with
        | d :: more =>
          let cp := (a - 240) * 262144 + (b - 128) * 4096 + (c - 128) * 64 + d - 128
          (55296 + (cp - 65536) / 1024) :: (56320 + (cp - 65536) % 1024) :: utf16Units more
        | [] => []
      | [] => []
    | [] => []

def javaLT (a b : Bytes) : Bool := lexLT (utf16Units a) (utf16Units b)

def insertById (n : Node) : List Node -> List Node
  | [] => [n]
  | x :: xs => if javaLT (recordId x) (recordId n) then x :: insertById n xs else n :: x :: xs

def sortedSection (tag : Bytes) (xs : List Node) : Node :=
  .mk tag [] (xs.foldr insertById [])

inductive Result where
  | accept | shape | duplicate | order | contentMismatch
  deriving BEq, DecidableEq

def checkRows (hash : Bytes -> Bytes) (tag : Bytes) (addressed : Bool) :
    Option Bytes -> List Node -> Result
  | _, [] => .accept
  | prior, n :: rest =>
    if n.tag != tag || n.scalars.isEmpty || (recordId n).isEmpty then .shape else
    if prior == some (recordId n) then .duplicate else
    if prior.any (fun p => !javaLT p (recordId n)) then .order else
    if addressed && recordId n != hash (preimage n) then .contentMismatch else
    checkRows hash tag addressed (some (recordId n)) rest

def indexedTable (hash : Bytes -> Bytes) (sectionTag recordTag : Bytes)
    (addressed : Bool) (table : Node) : Result :=
  if table.tag != sectionTag || !table.scalars.isEmpty then .shape else
    checkRows hash recordTag addressed none table.children

-- This is a separate evidence claim, not a stronger hash or Bundle.parse rule.
def claimedContent (expected actual : Node) : Bool := preimage expected == preimage actual

theorem encoding_grammar (t : Bytes) (s : List Bytes) (c : List Node) :
    encode (.mk t s c) = frame t ++ u32 s.length ++ s.flatMap frame ++
      u32 c.length ++ encodeForest c := rfl

theorem decode_exact (fuel : Nat) (input : Bytes) (n : Node)
    (h : decode fuel input = some n) : encode n = input := by
  unfold decode at h
  cases hp : parse fuel input with
  | none => simp [hp] at h
  | some pair =>
    rcases pair with ⟨value, rest⟩
    simp only [hp] at h
    split at h <;> simp_all

theorem preimage_ignores_id (t i j : Bytes) (s : List Bytes) (c : List Node) :
    preimage (.mk t (i :: s) c) = preimage (.mk t (j :: s) c) := rfl

theorem preimage_exact (t i : Bytes) (s : List Bytes) (c : List Node) :
    preimage (.mk t (i :: s) c) =
      encode (.mk (t ++ [47, 99, 111, 110, 116, 101, 110, 116]) s c) := rfl

theorem identified_hash (hash : Bytes -> Bytes) (t : Bytes) (s : List Bytes) (c : List Node) :
    recordId (identified hash t s c) = hash (preimage (identified hash t s c)) := rfl

theorem same_preimage_same_hash (hash : Bytes -> Bytes) (a b : Node)
    (h : preimage a = preimage b) : hash (preimage a) = hash (preimage b) := congrArg hash h

theorem claimed_content_iff (a b : Node) :
    claimedContent a b = true ↔ preimage a = preimage b := by
  simp [claimedContent]

theorem recomputed_content_still_compared (hash : Bytes -> Bytes) (t : Bytes)
    (s u : List Bytes) (c d : List Node)
    (h : preimage (.mk t ([] :: s) c) ≠ preimage (.mk t ([] :: u) d)) :
    claimedContent (identified hash t s c) (identified hash t u d) = false := by
  simpa only [claimedContent, identified, preimage, content, Node.tag, Node.scalars,
    Node.children, List.tail_cons, beq_eq_false_iff_ne] using h

theorem empty_table (hash : Bytes -> Bytes) (t r : Bytes) (a : Bool) :
    indexedTable hash t r a (.mk t [] []) = .accept := by
  simp [indexedTable, Node.tag, Node.scalars, Node.children, checkRows]

theorem accepted_section_shape (hash : Bytes -> Bytes) (t r : Bytes) (a : Bool) (n : Node)
    (h : indexedTable hash t r a n = .accept) : n.tag = t ∧ n.scalars = [] := by
  simp only [indexedTable] at h
  split at h <;> simp_all

theorem accepted_head (hash : Bytes -> Bytes) (t : Bytes) (a : Bool)
    (prior : Option Bytes) (n : Node) (ns : List Node)
    (h : checkRows hash t a prior (n :: ns) = .accept) :
    n.tag = t ∧ n.scalars ≠ [] ∧ recordId n ≠ [] ∧
      (prior.any (fun p => !javaLT p (recordId n))) = false ∧
      (a = true -> recordId n = hash (preimage n)) ∧
      checkRows hash t a (some (recordId n)) ns = .accept := by
  simp only [checkRows] at h
  split at h
  · simp_all
  · split at h
    · simp_all
    · split at h
      · simp_all
      · split at h <;> simp_all

theorem sorted_section_no_scalars (t : Bytes) (xs : List Node) :
    (sortedSection t xs).scalars = [] := rfl

theorem sorting_preserves_count (n : Node) (xs : List Node) :
    (insertById n xs).length = xs.length + 1 := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [insertById]; split <;> simp_all

def orderedRows : Option Bytes -> List Node -> Bool
  | _, [] => true
  | prior, n :: ns => !(prior.any (fun p => !javaLT p (recordId n))) &&
      orderedRows (some (recordId n)) ns

theorem accepted_rows_ordered (hash : Bytes -> Bytes) (t : Bytes) (a : Bool)
    (prior : Option Bytes) (ns : List Node)
    (h : checkRows hash t a prior ns = .accept) : orderedRows prior ns = true := by
  induction ns generalizing prior with
  | nil => rfl
  | cons n ns ih =>
    have head := accepted_head hash t a prior n ns h
    simp [orderedRows, head.2.2.2.1, ih _ head.2.2.2.2.2]

theorem insert_preserves_records (n : Node) (xs : List Node) :
    (insertById n xs).Perm (n :: xs) := by
  induction xs with
  | nil => exact List.Perm.refl _
  | cons x xs ih =>
    simp only [insertById]
    split
    · exact (ih.cons x).trans (List.Perm.swap n x xs)
    · exact List.Perm.refl _

theorem sorted_section_preserves_records (t : Bytes) (xs : List Node) :
    (sortedSection t xs).children.Perm xs := by
  simp only [sortedSection, Node.children]
  induction xs with
  | nil => exact List.Perm.refl _
  | cons x xs ih =>
    exact (insert_preserves_records x (xs.foldr insertById [])).trans (ih.cons x)

theorem ascii_units (xs : Bytes) (h : ∀ x ∈ xs, x < 128) : utf16Units xs = xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    have hx : x < 128 := h x (List.mem_cons_self ..)
    have ht : ∀ y ∈ xs, y < 128 := fun y hy => h y (List.mem_cons_of_mem x hy)
    rw [utf16Units.eq_def]
    simp only [if_pos hx]
    exact congrArg (List.cons x) (ih ht)

#print axioms encoding_grammar
#print axioms decode_exact
#print axioms preimage_ignores_id
#print axioms preimage_exact
#print axioms identified_hash
#print axioms same_preimage_same_hash
#print axioms claimed_content_iff
#print axioms recomputed_content_still_compared
#print axioms empty_table
#print axioms accepted_section_shape
#print axioms accepted_head
#print axioms sorted_section_no_scalars
#print axioms sorting_preserves_count
#print axioms accepted_rows_ordered
#print axioms insert_preserves_records
#print axioms sorted_section_preserves_records
#print axioms ascii_units

end ACGN.FifthFive.CanonicalWireTables
