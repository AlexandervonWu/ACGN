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

pred cap000105 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchB or some capBenchS) or some CapBenchB))) }
pred cap000105c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv7 and ((some CapBenchB or some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap000105 { cap000105 iff cap000105c }
check CapBenchEquivalent_cap000105 for 4
