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

pred cap001758 { ((some x: CapBenchA | x->x in capBenchR) and (inv10 and ((no CapBenchA and some CapBenchA) and some capBenchR))) }
pred cap001758c { (some x: CapBenchA | (x->x in capBenchR and (inv10 and ((no CapBenchA and some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap001758 { cap001758 iff cap001758c }
check CapBenchEquivalent_cap001758 for 4
