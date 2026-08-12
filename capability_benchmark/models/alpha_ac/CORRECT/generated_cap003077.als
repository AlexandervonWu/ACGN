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

pred cap003077 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
pred cap003077c { all renamed: CapBenchA | (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003077 { cap003077 iff cap003077c }
check CapBenchEquivalent_cap003077 for 4
