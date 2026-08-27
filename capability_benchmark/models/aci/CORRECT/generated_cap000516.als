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

pred cap000516 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv10 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
pred cap000516c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv10 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000516 { cap000516 iff cap000516c }
check CapBenchEquivalent_cap000516 for 4
