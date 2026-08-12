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

pred cap004219 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap004219c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap004219 { cap004219 iff cap004219c }
check CapBenchEquivalent_cap004219 for 4
