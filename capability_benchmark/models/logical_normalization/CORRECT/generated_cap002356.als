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

pred cap002356 { ((inv10 and ((some capBenchR and some capBenchR) or some capBenchS)) implies ((some CapBenchB or no CapBenchA) or some CapBenchA)) }
pred cap002356c { ((not (inv10 and ((some capBenchR and some capBenchR) or some capBenchS))) or ((some CapBenchB or no CapBenchA) or some CapBenchA)) }
assert CapBenchEquivalent_cap002356 { cap002356 iff cap002356c }
check CapBenchEquivalent_cap002356 for 4
