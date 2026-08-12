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

pred cap002800 { not always ((inv15 and ((some capBenchR and some capBenchS) or some capBenchR))) }
pred cap002800c { eventually (not (inv15 and ((some capBenchR and some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap002800 { cap002800 iff cap002800c }
check CapBenchEquivalent_cap002800 for 4
