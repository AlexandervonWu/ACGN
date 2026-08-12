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

pred cap000819 { ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) or ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB) or ((no CapBenchA and no CapBenchB) and no CapBenchA)) }
pred cap000819c { (((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB) or ((no CapBenchA and no CapBenchB) and no CapBenchA) or (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000819 { cap000819 iff cap000819c }
check CapBenchEquivalent_cap000819 for 4
