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

pred cap002840 { not (((inv10 and ((some capBenchR and no CapBenchA) or some capBenchS))) until (((some CapBenchB or some CapBenchA) or some CapBenchA))) }
pred cap002840c { ((not (inv10 and ((some capBenchR and no CapBenchA) or some capBenchS))) releases (not ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap002840 { cap002840 iff cap002840c }
check CapBenchEquivalent_cap002840 for 4
