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

pred cap001797 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
pred cap001797c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((some CapBenchB or some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap001797 { cap001797 iff cap001797c }
check CapBenchEquivalent_cap001797 for 4
