import CoursesPaidData

namespace CoursesRepairedNative
open CoursesPaidData

def p783Fast : List MatrixStep := [
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

def p783Declaration : List (String × Option Nat × Option Nat × Nat) := [
  ("delete", some 0, none, 1),
  ("keep", some 1, some 0, 0),
  ("insert", none, some 1, 1),
  ("insert", none, some 2, 1)]

def p826Fast : List MatrixStep := [
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

def p826Declaration : List (String × Option Nat × Option Nat × Nat) := [
  ("update", some 0, some 0, 1),
  ("update", some 1, some 1, 1),
  ("insert", none, some 2, 1)]

end CoursesRepairedNative
