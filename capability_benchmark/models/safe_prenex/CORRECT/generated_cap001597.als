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

pred cap001597 { ((all x: CapBenchA | x->x in capBenchR) or (inv13 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
pred cap001597c { (all x: CapBenchA | (x->x in capBenchR or (inv13 and ((some CapBenchB or some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001597 { cap001597 iff cap001597c }
check CapBenchEquivalent_cap001597 for 4
