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

pred cap000847 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv15 and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap000847c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv15 and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000847 { cap000847 iff cap000847c }
check CapBenchEquivalent_cap000847 for 4
