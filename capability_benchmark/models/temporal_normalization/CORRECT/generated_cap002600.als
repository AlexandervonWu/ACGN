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

pred cap002600 { not (((inv15 and ((some capBenchR and some capBenchR) or some CapBenchB))) until (((some CapBenchB or no CapBenchA) or some capBenchR))) }
pred cap002600c { ((not (inv15 and ((some capBenchR and some capBenchR) or some CapBenchB))) releases (not ((some CapBenchB or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002600 { cap002600 iff cap002600c }
check CapBenchEquivalent_cap002600 for 4
