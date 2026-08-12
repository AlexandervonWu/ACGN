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

pred inv12 {
all t : Teacher | some t.Teaches.Groups
}

pred inv12c {
 all x:Teacher | some x.Teaches.Groups
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001673 { ((all x: CapBenchA | x->x in capBenchR) or (inv12 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
pred cap001673c { (all x: CapBenchA | (x->x in capBenchR or (inv12 and ((some capBenchS or some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001673 { cap001673 iff cap001673c }
check CapBenchEquivalent_cap001673 for 4
