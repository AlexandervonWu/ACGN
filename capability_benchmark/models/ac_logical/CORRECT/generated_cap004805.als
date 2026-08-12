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

pred cap004805 { not ((inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004805c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)))) }
assert CapBenchEquivalent_cap004805 { cap004805 iff cap004805c }
check CapBenchEquivalent_cap004805 for 4
