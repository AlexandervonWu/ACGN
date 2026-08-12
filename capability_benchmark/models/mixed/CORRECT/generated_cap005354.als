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

pred cap005354 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchA and some capBenchR) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap005354c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) or (not (inv7 and ((no CapBenchA and some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap005354 { cap005354 iff cap005354c }
check CapBenchEquivalent_cap005354 for 4
