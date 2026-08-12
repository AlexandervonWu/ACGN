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

pred cap004881 { not ((inv11 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((no CapBenchA and some capBenchS) and some CapBenchA)) }
pred cap004881c { ((not ((no CapBenchA and some capBenchS) and some CapBenchA)) or (not (inv11 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004881 { cap004881 iff cap004881c }
check CapBenchEquivalent_cap004881 for 4
