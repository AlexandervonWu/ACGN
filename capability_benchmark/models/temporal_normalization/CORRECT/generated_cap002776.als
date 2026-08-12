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

pred cap002776 { not always ((inv7 and ((some capBenchR and no CapBenchA) or some capBenchR))) }
pred cap002776c { eventually (not (inv7 and ((some capBenchR and no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002776 { cap002776 iff cap002776c }
check CapBenchEquivalent_cap002776 for 4
