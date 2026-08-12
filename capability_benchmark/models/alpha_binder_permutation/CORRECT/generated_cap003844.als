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
some c : Class, p : Person | p -> c in Teaches and p in Teacher
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

pred cap003844 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
pred cap003844c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003844 { cap003844 iff cap003844c }
check CapBenchEquivalent_cap003844 for 4
