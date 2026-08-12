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

pred cap002628 { not historically ((inv7 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
pred cap002628c { once (not (inv7 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002628 { cap002628 iff cap002628c }
check CapBenchEquivalent_cap002628 for 4
