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

pred cap002969 { not eventually ((inv3 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002969c { always (not (inv3 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002969 { cap002969 iff cap002969c }
check CapBenchEquivalent_cap002969 for 4
