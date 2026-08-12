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

pred cap002458 { ((inv15 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) implies ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap002458c { ((not (inv15 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) or ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
assert CapBenchEquivalent_cap002458 { cap002458 iff cap002458c }
check CapBenchEquivalent_cap002458 for 4
