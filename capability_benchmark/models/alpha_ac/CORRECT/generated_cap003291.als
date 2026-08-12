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
all x: Person | x in Student implies x not in Teacher
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

pred cap003291 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or some capBenchR) and some capBenchR)) and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003291c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchB or some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap003291 { cap003291 iff cap003291c }
check CapBenchEquivalent_cap003291 for 4
