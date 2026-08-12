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

pred cap004212 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((some capBenchR and no CapBenchA) or no CapBenchB))) }
pred cap004212c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some capBenchR and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap004212 { cap004212 iff cap004212c }
check CapBenchEquivalent_cap004212 for 4
