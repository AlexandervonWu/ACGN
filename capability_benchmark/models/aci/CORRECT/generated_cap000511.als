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

pred cap000511 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap000511c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap000511 { cap000511 iff cap000511c }
check CapBenchEquivalent_cap000511 for 4
