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

pred cap005035 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv12 and ((no CapBenchB or some capBenchR) and some CapBenchA)) and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
pred cap005035c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchA) or no CapBenchB)) or (not (inv12 and ((no CapBenchB or some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005035 { cap005035 iff cap005035c }
check CapBenchEquivalent_cap005035 for 4
