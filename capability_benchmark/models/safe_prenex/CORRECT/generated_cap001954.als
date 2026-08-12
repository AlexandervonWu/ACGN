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

pred cap001954 { ((some x: CapBenchA | x->x in capBenchR) and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001954c { (some x: CapBenchA | (x->x in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001954 { cap001954 iff cap001954c }
check CapBenchEquivalent_cap001954 for 4
