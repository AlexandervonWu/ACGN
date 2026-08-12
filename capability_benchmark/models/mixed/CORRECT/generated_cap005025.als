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

pred cap005025 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some CapBenchB or no CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB))) }
pred cap005025c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB)) or (not (inv7 and ((some CapBenchB or no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005025 { cap005025 iff cap005025c }
check CapBenchEquivalent_cap005025 for 4
