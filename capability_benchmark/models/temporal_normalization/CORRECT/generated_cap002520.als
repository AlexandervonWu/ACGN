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

pred cap002520 { not historically ((inv1 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
pred cap002520c { once (not (inv1 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap002520 { cap002520 iff cap002520c }
check CapBenchEquivalent_cap002520 for 4
