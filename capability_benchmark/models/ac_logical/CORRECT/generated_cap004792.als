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

pred cap004792 { not ((inv10 and ((some capBenchR and some capBenchR) or some capBenchR)) and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004792c { ((not ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv10 and ((some capBenchR and some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap004792 { cap004792 iff cap004792c }
check CapBenchEquivalent_cap004792 for 4
