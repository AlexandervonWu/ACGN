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

pred cap002958 { not historically ((inv1 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002958c { once (not (inv1 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002958 { cap002958 iff cap002958c }
check CapBenchEquivalent_cap002958 for 4
