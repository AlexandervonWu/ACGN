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
Person = Student
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

pred cap000990 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv1 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap000990c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv1 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000990 { cap000990 iff cap000990c }
check CapBenchEquivalent_cap000990 for 4
