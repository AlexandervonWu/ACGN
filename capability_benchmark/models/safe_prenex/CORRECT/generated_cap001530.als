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

pred cap001530 { ((some x: CapBenchA | x->x in capBenchR) and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA))) }
pred cap001530c { (some x: CapBenchA | (x->x in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001530 { cap001530 iff cap001530c }
check CapBenchEquivalent_cap001530 for 4
