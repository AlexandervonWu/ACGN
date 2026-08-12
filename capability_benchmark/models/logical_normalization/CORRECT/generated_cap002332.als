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

pred inv11 {
all c: Class | some c.Groups implies (some t: Teacher | t in Teaches.c)
}

pred inv11c {
  all c:Class | some c.Groups implies some Teacher&Teaches.c
}


check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002332 { ((inv11 and ((some capBenchR and some CapBenchB) or some capBenchS)) implies ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002332c { ((not (inv11 and ((some capBenchR and some CapBenchB) or some capBenchS))) or ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002332 { cap002332 iff cap002332c }
check CapBenchEquivalent_cap002332 for 4
