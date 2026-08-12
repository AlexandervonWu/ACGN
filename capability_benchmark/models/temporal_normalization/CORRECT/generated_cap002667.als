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

pred cap002667 { not (((inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) since (((some capBenchR and no CapBenchA) or some capBenchS))) }
pred cap002667c { ((not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) triggered (not ((some capBenchR and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002667 { cap002667 iff cap002667c }
check CapBenchEquivalent_cap002667 for 4
