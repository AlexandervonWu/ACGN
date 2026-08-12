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

pred cap002723 { not eventually ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap002723c { always (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002723 { cap002723 iff cap002723c }
check CapBenchEquivalent_cap002723 for 4
