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

pred inv10 {
all c : Class, s : Student | some g : Group | c->s->g in Groups
}

pred inv10c {
  all c:Class,s:Student | some s.(c.Groups)
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003751 { all x, y: CapBenchA | (x->y in capBenchR and (inv10 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap003751c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv10 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003751 { cap003751 iff cap003751c }
check CapBenchEquivalent_cap003751 for 4
