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

pred inv3 {
no (Teacher & Student)
}

pred inv3c {
 no Student & Teacher 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004422 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004422c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004422 { cap004422 iff cap004422c }
check CapBenchEquivalent_cap004422 for 4
