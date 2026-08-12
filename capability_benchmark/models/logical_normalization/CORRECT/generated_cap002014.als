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

pred cap002014 { ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) implies ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
pred cap002014c { ((not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) or ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
assert CapBenchEquivalent_cap002014 { cap002014 iff cap002014c }
check CapBenchEquivalent_cap002014 for 4
