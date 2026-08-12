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

pred cap002322 { not (all x: CapBenchA | (x->x in capBenchR and (inv7 and ((no CapBenchA and some CapBenchA) and some capBenchS)))) }
pred cap002322c { some x: CapBenchA | not (x->x in capBenchR and (inv7 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002322 { cap002322 iff cap002322c }
check CapBenchEquivalent_cap002322 for 4
