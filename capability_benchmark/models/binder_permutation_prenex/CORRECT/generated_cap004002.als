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

pred cap004002 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchA and some CapBenchA) and some CapBenchA))) }
pred cap004002c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap004002 { cap004002 iff cap004002c }
check CapBenchEquivalent_cap004002 for 4
