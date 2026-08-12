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

pred cap000530 { ((inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) and ((no CapBenchB or some CapBenchB) and no CapBenchB) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap000530c { (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS) and (inv10 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) and ((no CapBenchB or some CapBenchB) and no CapBenchB)) }
assert CapBenchEquivalent_cap000530 { cap000530 iff cap000530c }
check CapBenchEquivalent_cap000530 for 4
