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

pred cap002601 { not (((inv10 and ((some capBenchS or some capBenchR) or some CapBenchB))) since (((no CapBenchA and no CapBenchA) and some capBenchR))) }
pred cap002601c { ((not (inv10 and ((some capBenchS or some capBenchR) or some CapBenchB))) triggered (not ((no CapBenchA and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap002601 { cap002601 iff cap002601c }
check CapBenchEquivalent_cap002601 for 4
