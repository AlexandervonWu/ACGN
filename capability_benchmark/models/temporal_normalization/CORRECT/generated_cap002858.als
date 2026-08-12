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

pred cap002858 { not (((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) until (((no CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap002858c { ((not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) releases (not ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap002858 { cap002858 iff cap002858c }
check CapBenchEquivalent_cap002858 for 4
