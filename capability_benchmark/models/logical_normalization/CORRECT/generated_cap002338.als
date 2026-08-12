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

pred inv15 {
all p:Person | some (^Tutors.p & Teacher)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002338 { ((inv15 and ((no CapBenchA and no CapBenchA) and some capBenchS)) implies ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002338c { ((not (inv15 and ((no CapBenchA and no CapBenchA) and some capBenchS))) or ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002338 { cap002338 iff cap002338c }
check CapBenchEquivalent_cap002338 for 4
