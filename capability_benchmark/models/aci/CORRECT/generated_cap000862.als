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

pred cap000862 { (inv1 and ((no CapBenchA and some capBenchS) and some capBenchS)) }
pred cap000862c { ((inv1 and ((no CapBenchA and some capBenchS) and some capBenchS)) and (inv1 and ((no CapBenchA and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap000862 { cap000862 iff cap000862c }
check CapBenchEquivalent_cap000862 for 4
