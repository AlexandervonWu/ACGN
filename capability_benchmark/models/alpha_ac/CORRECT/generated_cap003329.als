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

pred cap003329 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or some CapBenchB) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003329c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003329 { cap003329 iff cap003329c }
check CapBenchEquivalent_cap003329 for 4
