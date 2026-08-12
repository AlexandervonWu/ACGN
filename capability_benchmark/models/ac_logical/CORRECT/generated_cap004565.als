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

pred cap004565 { not ((inv3 and ((some CapBenchB or some CapBenchA) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)) }
pred cap004565c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)) or (not (inv3 and ((some CapBenchB or some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004565 { cap004565 iff cap004565c }
check CapBenchEquivalent_cap004565 for 4
