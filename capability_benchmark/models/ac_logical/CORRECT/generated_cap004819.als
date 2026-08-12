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

pred cap004819 { not ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004819c { ((not ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004819 { cap004819 iff cap004819c }
check CapBenchEquivalent_cap004819 for 4
