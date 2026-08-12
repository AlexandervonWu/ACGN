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
all c : Class | some (Teaches.c & Teacher)
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

pred cap001064 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
pred cap001064c { all a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap001064 { cap001064 iff cap001064c }
check CapBenchEquivalent_cap001064 for 4
