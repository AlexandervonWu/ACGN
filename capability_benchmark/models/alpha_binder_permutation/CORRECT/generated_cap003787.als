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

pred cap003787 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) }
pred cap003787c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003787 { cap003787 iff cap003787c }
check CapBenchEquivalent_cap003787 for 4
