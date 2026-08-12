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

pred inv2 {
all p : Person | p not in Teacher
}

pred inv2c {
  no Teacher
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004388 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004388c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004388 { cap004388 iff cap004388c }
check CapBenchEquivalent_cap004388 for 4
