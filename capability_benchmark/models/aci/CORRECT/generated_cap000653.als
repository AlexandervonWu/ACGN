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

pred cap000653 { (inv1 and ((some CapBenchB or no CapBenchB) or no CapBenchA)) }
pred cap000653c { ((inv1 and ((some CapBenchB or no CapBenchB) or no CapBenchA)) or (inv1 and ((some CapBenchB or no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000653 { cap000653 iff cap000653c }
check CapBenchEquivalent_cap000653 for 4
