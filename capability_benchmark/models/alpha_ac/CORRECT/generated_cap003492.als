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

pred cap003492 { all x: CapBenchA | (x->x in capBenchR and (inv10 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchB) or no CapBenchA)) }
pred cap003492c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv10 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003492 { cap003492 iff cap003492c }
check CapBenchEquivalent_cap003492 for 4
