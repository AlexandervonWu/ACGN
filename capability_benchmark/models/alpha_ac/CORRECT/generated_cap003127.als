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

pred cap003127 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((some capBenchR and some capBenchS) or some capBenchR)) }
pred cap003127c { all renamed: CapBenchA | (((some capBenchR and some capBenchS) or some capBenchR) and renamed->renamed in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003127 { cap003127 iff cap003127c }
check CapBenchEquivalent_cap003127 for 4
