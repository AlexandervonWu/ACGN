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

pred cap002532 { not historically ((inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
pred cap002532c { once (not (inv1 and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap002532 { cap002532 iff cap002532c }
check CapBenchEquivalent_cap002532 for 4
