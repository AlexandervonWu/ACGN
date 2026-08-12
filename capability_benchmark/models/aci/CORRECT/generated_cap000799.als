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

pred inv5 {
some c : Class | some x : Teacher | x->c in Teaches
}

pred inv5c {
  some Teacher.Teaches
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000799 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv5 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
pred cap000799c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv5 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap000799 { cap000799 iff cap000799c }
check CapBenchEquivalent_cap000799 for 4
