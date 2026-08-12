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

pred cap000804 { (some ((CapBenchA.capBenchR).capBenchR) and (inv10 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap000804c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv10 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap000804 { cap000804 iff cap000804c }
check CapBenchEquivalent_cap000804 for 4
