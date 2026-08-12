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

pred inv1 {
all p:Person | p in Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001693 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
pred cap001693c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((some CapBenchB or some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001693 { cap001693 iff cap001693c }
check CapBenchEquivalent_cap001693 for 4
