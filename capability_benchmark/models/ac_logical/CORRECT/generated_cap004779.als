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

pred cap004779 { not ((inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)) and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004779c { ((not ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv11 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap004779 { cap004779 iff cap004779c }
check CapBenchEquivalent_cap004779 for 4
