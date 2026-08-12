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

pred cap001799 { ((all x: CapBenchA | x->x in capBenchR) or (inv10 and ((no CapBenchB or some capBenchS) and some capBenchR))) }
pred cap001799c { (all x: CapBenchA | (x->x in capBenchR or (inv10 and ((no CapBenchB or some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap001799 { cap001799 iff cap001799c }
check CapBenchEquivalent_cap001799 for 4
