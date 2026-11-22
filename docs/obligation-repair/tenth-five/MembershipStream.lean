import Membership

namespace ACGN.Tenth.Membership

structure Key where
  e : Engine
  p : Polarity
  l : Head
  r : Head
  w : Bool
  a : Bool
  x : Bool
  deriving DecidableEq, Repr

def decisions : List Key :=
  ([.raw,.normal,.saturation] : List Engine).flatMap fun e =>
  ([.positive,.negative] : List Polarity).flatMap fun p =>
  ([.empty,.universal,.ordinary] : List Head).flatMap fun l =>
  ([.empty,.universal,.ordinary] : List Head).flatMap fun r =>
  [false,true].flatMap fun w => [false,true].flatMap fun a =>
  [false,true].flatMap fun x => [⟨e,p,l,r,w,a,x⟩]

def engineText : Engine → String | .raw => "R" | .normal => "N" | .saturation => "S"
def modeText : Polarity → String | .positive => "IN" | .negative => "NOT_IN"
def headText : Head → String | .empty => "0" | .universal => "1" | .ordinary => "2"
def bit (b : Bool) : String := if b then "1" else "0"
def resultText (p : Polarity) : Result → String
  | .literal true => "T" | .literal false => "F" | .original => "K"
  | .cardinality => match p with | .positive => "NO" | .negative => "SOME"

def printRow (k : Key) (answer : Result) : String := String.intercalate "\t"
  [engineText k.e,modeText k.p,headText k.l,headText k.r,bit k.w,bit k.a,bit k.x] ++ "\t" ++ resultText k.p answer

def program (k : Key) := choose k.e k.p k.l k.r k.w k.a k.x
def checkStream (rows : List String) : Bool := decide (rows = decisions.map (fun k => printRow k (program k)))

theorem engines (e : Engine) : e ∈ ([.raw,.normal,.saturation] : List Engine) := by cases e <;> simp
theorem modes (p : Polarity) : p ∈ ([.positive,.negative] : List Polarity) := by cases p <;> simp
theorem heads (h : Head) : h ∈ ([.empty,.universal,.ordinary] : List Head) := by cases h <;> simp
theorem bits (b : Bool) : b ∈ ([false,true] : List Bool) := by cases b <;> simp

theorem registered_key (k : Key) : k ∈ decisions := by
  rcases k with ⟨e,p,l,r,w,a,x⟩
  have bind {α β : Type} {xs : List α} {f : α → List β} {v : β} {u : α}
      (h : u ∈ xs) (t : v ∈ f u) : v ∈ xs.flatMap f := List.mem_flatMap.mpr ⟨u,h,t⟩
  unfold decisions
  apply bind (engines e)
  apply bind (modes p)
  apply bind (heads l)
  apply bind (heads r)
  apply bind (bits w)
  apply bind (bits a)
  apply bind (bits x)
  simp

theorem accepted_instructions (rows : List String) (ok : checkStream rows = true) (k : Key) :
    printRow k (program k) ∈ rows := by
  obtain rfl := of_decide_eq_true ok
  exact List.mem_map.mpr ⟨k,registered_key k,rfl⟩

def readResult (p : Polarity) (s : String) : Option Result :=
  if s = "T" then some (.literal true)
  else if s = "F" then some (.literal false)
  else if s = "K" then some .original
  else if s = (match p with | .positive => "NO" | .negative => "SOME") then some .cardinality
  else none

theorem read_result_roundtrip (p : Polarity) (r : Result) : readResult p (resultText p r) = some r := by
  cases p <;> cases r with
  | literal b => cases b <;> rfl
  | original => rfl
  | cardinality => rfl

theorem exact_observed_answer (rows : List String) (ok : checkStream rows = true)
    (k : Key) (i : Nat) (ki : decisions[i]? = some k) (observed : Result)
    (actual : rows[i]? = some (printRow k observed)) : observed = program k := by
  obtain rfl := of_decide_eq_true ok
  rw [List.getElem?_map,ki] at actual
  have equal : printRow k (program k) = printRow k observed := Option.some.inj actual
  have code : resultText k.p (program k) = resultText k.p observed := by simpa [printRow] using equal
  have equalResult := congrArg (readResult k.p) code
  rw [read_result_roundtrip,read_result_roundtrip] at equalResult
  exact (Option.some.inj equalResult).symm

end ACGN.Tenth.Membership
#print axioms ACGN.Tenth.Membership.registered_key
#print axioms ACGN.Tenth.Membership.accepted_instructions
#print axioms ACGN.Tenth.Membership.exact_observed_answer
#print axioms ACGN.Tenth.Membership.engines
#print axioms ACGN.Tenth.Membership.modes
#print axioms ACGN.Tenth.Membership.heads
#print axioms ACGN.Tenth.Membership.bits
#print axioms ACGN.Tenth.Membership.read_result_roundtrip
