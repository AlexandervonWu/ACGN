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

pred cap004019 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv13 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap004019c { some a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap004019 { cap004019 iff cap004019c }
check CapBenchEquivalent_cap004019 for 4
