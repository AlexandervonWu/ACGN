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

pred inv7 {
Class in Teacher.Teaches
}

pred inv7c {
  all c:Class | some Teacher&Teaches.c
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001763 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap001763c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap001763 { cap001763 iff cap001763c }
check CapBenchEquivalent_cap001763 for 4
