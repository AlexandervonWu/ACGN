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

pred cap005039 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)) and ((some capBenchR and no CapBenchA) or no CapBenchB))) }
pred cap005039c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchA) or no CapBenchB)) or (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005039 { cap005039 iff cap005039c }
check CapBenchEquivalent_cap005039 for 4
