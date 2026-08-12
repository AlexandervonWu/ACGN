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

pred cap003668 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
pred cap003668c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv12 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap003668 { cap003668 iff cap003668c }
check CapBenchEquivalent_cap003668 for 4
