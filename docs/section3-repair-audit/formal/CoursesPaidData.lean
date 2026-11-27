import Std

namespace CoursesPaidData

structure MatrixStep where
  kind : String
  source : Option String
  target : Option String
  cost : Nat
  deriving DecidableEq

def p783Costs : List Nat := [23, 23, 22, 23, 22]

def p783FastMatrix : List MatrixStep := [
  ⟨"node", (some "$"), (some "$"), 0⟩,
  ⟨"node", (some "$/0"), (some "$/0"), 1⟩,
  ⟨"insert", none, (some "$/0/0"), 5⟩,
  ⟨"insert", none, (some "$/0/1"), 3⟩,
  ⟨"node", (some "$/0/0"), (some "$/0/2"), 1⟩,
  ⟨"node", (some "$/0/0/0"), (some "$/0/2/0"), 0⟩,
  ⟨"node", (some "$/0/0/0/0"), (some "$/0/2/0/0"), 1⟩,
  ⟨"node", (some "$/0/0/0/1"), (some "$/0/2/0/1"), 0⟩,
  ⟨"node", (some "$/0/0/0/1/0"), (some "$/0/2/0/1/0"), 0⟩,
  ⟨"node", (some "$/0/0/0/1/1"), (some "$/0/2/0/1/1"), 0⟩,
  ⟨"node", (some "$/0/0/1"), (some "$/0/2/1"), 1⟩,
  ⟨"insert", none, (some "$/0/2/1/0"), 1⟩,
  ⟨"node", (some "$/0/0/1/0"), (some "$/0/2/1/1"), 1⟩,
  ⟨"node", (some "$/0/0/1/0/0"), (some "$/0/2/1/1/0"), 1⟩,
  ⟨"delete", (some "$/0/0/1/0/0/0"), none, 1⟩,
  ⟨"delete", (some "$/0/0/1/0/0/1"), none, 1⟩,
  ⟨"node", (some "$/0/0/1/0/1"), (some "$/0/2/1/1/1"), 1⟩,
  ⟨"delete", (some "$/0/1"), none, 4⟩]

def p783FastExisting : List Bool := [true, true, true, false, false]

def p783CertifiedMatrix : List MatrixStep := [
  ⟨"node", (some "$"), (some "$"), 0⟩,
  ⟨"node", (some "$/0"), (some "$/0"), 1⟩,
  ⟨"insert", none, (some "$/0/0"), 5⟩,
  ⟨"insert", none, (some "$/0/1"), 3⟩,
  ⟨"node", (some "$/0/0"), (some "$/0/2"), 1⟩,
  ⟨"node", (some "$/0/0/0"), (some "$/0/2/0"), 0⟩,
  ⟨"node", (some "$/0/0/0/0"), (some "$/0/2/0/0"), 0⟩,
  ⟨"node", (some "$/0/0/0/1"), (some "$/0/2/0/1"), 0⟩,
  ⟨"node", (some "$/0/0/0/1/0"), (some "$/0/2/0/1/0"), 1⟩,
  ⟨"node", (some "$/0/0/0/1/1"), (some "$/0/2/0/1/1"), 0⟩,
  ⟨"node", (some "$/0/0/1"), (some "$/0/2/1"), 1⟩,
  ⟨"insert", none, (some "$/0/2/1/0"), 1⟩,
  ⟨"node", (some "$/0/0/1/0"), (some "$/0/2/1/1"), 1⟩,
  ⟨"node", (some "$/0/0/1/0/0"), (some "$/0/2/1/1/0"), 1⟩,
  ⟨"delete", (some "$/0/0/1/0/0/0"), none, 1⟩,
  ⟨"delete", (some "$/0/0/1/0/0/1"), none, 1⟩,
  ⟨"node", (some "$/0/0/1/0/1"), (some "$/0/2/1/1/1"), 1⟩,
  ⟨"delete", (some "$/0/1"), none, 4⟩]

def p783CertifiedExisting : List Bool := [true, true, false, true, true]

def p826Costs : List Nat := [22, 22, 21, 21, 21]

def p826FastMatrix : List MatrixStep := [
  ⟨"node", (some "$"), (some "$"), 0⟩,
  ⟨"node", (some "$/0"), (some "$/0"), 1⟩,
  ⟨"insert", none, (some "$/0/0"), 5⟩,
  ⟨"node", (some "$/0/0"), (some "$/0/1"), 1⟩,
  ⟨"insert", none, (some "$/0/1/0"), 3⟩,
  ⟨"node", (some "$/0/0/0"), (some "$/0/1/1"), 0⟩,
  ⟨"node", (some "$/0/0/0/0"), (some "$/0/1/1/0"), 1⟩,
  ⟨"node", (some "$/0/0/0/1"), (some "$/0/1/1/1"), 0⟩,
  ⟨"node", (some "$/0/0/0/1/0"), (some "$/0/1/1/1/0"), 0⟩,
  ⟨"node", (some "$/0/0/0/1/1"), (some "$/0/1/1/1/1"), 0⟩,
  ⟨"delete", (some "$/0/0/1"), none, 6⟩,
  ⟨"delete", (some "$/0/1"), none, 4⟩]

def p826FastExisting : List Bool := [true, true, true, true, false]

def p826CertifiedMatrix : List MatrixStep := [
  ⟨"node", (some "$"), (some "$"), 0⟩,
  ⟨"node", (some "$/0"), (some "$/0"), 1⟩,
  ⟨"node", (some "$/0/0"), (some "$/0/0"), 1⟩,
  ⟨"node", (some "$/0/0/0"), (some "$/0/0/0"), 1⟩,
  ⟨"node", (some "$/0/0/0/0"), (some "$/0/0/0/0"), 0⟩,
  ⟨"node", (some "$/0/0/0/1"), (some "$/0/0/0/1"), 1⟩,
  ⟨"delete", (some "$/0/0/0/1/0"), none, 1⟩,
  ⟨"delete", (some "$/0/0/0/1/1"), none, 1⟩,
  ⟨"node", (some "$/0/0/1"), (some "$/0/0/1"), 1⟩,
  ⟨"delete", (some "$/0/0/1/0"), none, 5⟩,
  ⟨"node", (some "$/0/1"), (some "$/0/1"), 1⟩,
  ⟨"insert", none, (some "$/0/1/0"), 3⟩,
  ⟨"node", (some "$/0/1/0"), (some "$/0/1/1"), 1⟩,
  ⟨"node", (some "$/0/1/0/0"), (some "$/0/1/1/0"), 1⟩,
  ⟨"node", (some "$/0/1/0/1"), (some "$/0/1/1/1"), 1⟩,
  ⟨"insert", none, (some "$/0/1/1/1/0"), 1⟩,
  ⟨"insert", none, (some "$/0/1/1/1/1"), 1⟩]

def p826CertifiedExisting : List Bool := [true, true, false, true, true]

end CoursesPaidData
