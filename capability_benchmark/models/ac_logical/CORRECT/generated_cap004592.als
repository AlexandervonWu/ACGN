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

pred cap004592 { not ((inv11 and ((some capBenchR and no CapBenchB) or some CapBenchB)) and ((some CapBenchB or some CapBenchB) or some capBenchR)) }
pred cap004592c { ((not ((some CapBenchB or some CapBenchB) or some capBenchR)) or (not (inv11 and ((some capBenchR and no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004592 { cap004592 iff cap004592c }
check CapBenchEquivalent_cap004592 for 4
