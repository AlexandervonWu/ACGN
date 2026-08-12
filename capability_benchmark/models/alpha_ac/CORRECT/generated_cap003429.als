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

pred cap003429 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and no CapBenchB) and some CapBenchB)) }
pred cap003429c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and some CapBenchB) and renamed->renamed in capBenchR and (inv13 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003429 { cap003429 iff cap003429c }
check CapBenchEquivalent_cap003429 for 4
