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

pred cap000173 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv10 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
pred cap000173c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv10 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap000173 { cap000173 iff cap000173c }
check CapBenchEquivalent_cap000173 for 4
