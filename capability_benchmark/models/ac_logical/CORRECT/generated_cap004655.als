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

pred cap004655 { not ((inv11 and ((no CapBenchB or no CapBenchB) and no CapBenchA)) and ((some CapBenchA and some CapBenchB) or some capBenchS)) }
pred cap004655c { ((not ((some CapBenchA and some CapBenchB) or some capBenchS)) or (not (inv11 and ((no CapBenchB or no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004655 { cap004655 iff cap004655c }
check CapBenchEquivalent_cap004655 for 4
