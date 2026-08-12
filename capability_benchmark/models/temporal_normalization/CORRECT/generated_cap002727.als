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

pred cap002727 { not (((inv11 and ((no CapBenchB or some capBenchR) and no CapBenchB))) since (((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002727c { ((not (inv11 and ((no CapBenchB or some capBenchR) and no CapBenchB))) triggered (not ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002727 { cap002727 iff cap002727c }
check CapBenchEquivalent_cap002727 for 4
