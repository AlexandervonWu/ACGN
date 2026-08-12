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
all c: Class | some Person.(c.Groups) implies some t:Teacher | t in Teaches.c
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

pred cap004983 { not ((inv11 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and no CapBenchA) or no CapBenchA)) }
pred cap004983c { ((not ((some CapBenchA and no CapBenchA) or no CapBenchA)) or (not (inv11 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004983 { cap004983 iff cap004983c }
check CapBenchEquivalent_cap004983 for 4
