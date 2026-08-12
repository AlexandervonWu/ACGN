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

pred cap003667 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap003667c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap003667 { cap003667 iff cap003667c }
check CapBenchEquivalent_cap003667 for 4
