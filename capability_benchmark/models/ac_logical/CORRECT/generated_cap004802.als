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

pred cap004802 { not ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004802c { ((not ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap004802 { cap004802 iff cap004802c }
check CapBenchEquivalent_cap004802 for 4
