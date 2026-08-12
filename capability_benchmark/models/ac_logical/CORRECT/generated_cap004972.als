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

pred cap004972 { not ((inv11 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some CapBenchA) or no CapBenchA)) }
pred cap004972c { ((not ((some capBenchS or some CapBenchA) or no CapBenchA)) or (not (inv11 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004972 { cap004972 iff cap004972c }
check CapBenchEquivalent_cap004972 for 4
