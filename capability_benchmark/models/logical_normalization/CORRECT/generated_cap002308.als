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

pred cap002308 { ((inv10 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) implies ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002308c { ((not (inv10 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) or ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002308 { cap002308 iff cap002308c }
check CapBenchEquivalent_cap002308 for 4
