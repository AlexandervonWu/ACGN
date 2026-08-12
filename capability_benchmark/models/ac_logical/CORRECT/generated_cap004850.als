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

pred cap004850 { not ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) and ((no CapBenchB or some CapBenchB) and some CapBenchA)) }
pred cap004850c { ((not ((no CapBenchB or some CapBenchB) and some CapBenchA)) or (not (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004850 { cap004850 iff cap004850c }
check CapBenchEquivalent_cap004850 for 4
