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
Class in Teacher.Teaches
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

pred cap004995 { not ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and no CapBenchB) or no CapBenchA)) }
pred cap004995c { ((not ((some capBenchR and no CapBenchB) or no CapBenchA)) or (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004995 { cap004995 iff cap004995c }
check CapBenchEquivalent_cap004995 for 4
