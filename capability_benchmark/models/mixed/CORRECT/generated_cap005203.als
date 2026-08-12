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

pred cap005203 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv10 and ((no CapBenchB or some CapBenchB) and no CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap005203c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv10 and ((no CapBenchB or some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005203 { cap005203 iff cap005203c }
check CapBenchEquivalent_cap005203 for 4
