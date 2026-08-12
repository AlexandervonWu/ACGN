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

pred cap002801 { not eventually ((inv1 and ((some capBenchS or some capBenchS) or some capBenchR))) }
pred cap002801c { always (not (inv1 and ((some capBenchS or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap002801 { cap002801 iff cap002801c }
check CapBenchEquivalent_cap002801 for 4
