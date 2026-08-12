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

pred cap002655 { not (((inv10 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) since (((some CapBenchA and some CapBenchB) or some capBenchS))) }
pred cap002655c { ((not (inv10 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) triggered (not ((some CapBenchA and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002655 { cap002655 iff cap002655c }
check CapBenchEquivalent_cap002655 for 4
