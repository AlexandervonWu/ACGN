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

pred cap004729 { not ((inv11 and ((some capBenchS or some capBenchR) or no CapBenchB)) and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004729c { ((not ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv11 and ((some capBenchS or some capBenchR) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004729 { cap004729 iff cap004729c }
check CapBenchEquivalent_cap004729 for 4
