sig Person  {
	Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv13 {
Person.Tutors in Student and Tutors.Person in Teacher
}

pred inv13c {
  Tutors in Teacher -> Student
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004404 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv13 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004404c { some a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004404 { cap004404 iff cap004404c }
check CapBenchEquivalent_cap004404 for 4
