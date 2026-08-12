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

pred cap004202 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
pred cap004202c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap004202 { cap004202 iff cap004202c }
check CapBenchEquivalent_cap004202 for 4
