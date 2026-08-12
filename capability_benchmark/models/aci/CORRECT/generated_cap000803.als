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

pred cap000803 { (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) }
pred cap000803c { ((inv10 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) or (inv10 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap000803 { cap000803 iff cap000803c }
check CapBenchEquivalent_cap000803 for 4
