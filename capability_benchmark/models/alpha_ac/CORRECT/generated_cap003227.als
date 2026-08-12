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
Tutors in (Teacher->Student)
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

pred cap003227 { all x: CapBenchA | (x->x in capBenchR and (inv13 and ((no CapBenchB or some capBenchR) and no CapBenchB)) and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003227c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv13 and ((no CapBenchB or some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap003227 { cap003227 iff cap003227c }
check CapBenchEquivalent_cap003227 for 4
