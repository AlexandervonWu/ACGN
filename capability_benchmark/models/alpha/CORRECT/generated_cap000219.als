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

pred cap000219 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv10 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap000219c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv10 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000219 { cap000219 iff cap000219c }
check CapBenchEquivalent_cap000219 for 4
