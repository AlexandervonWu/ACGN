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

pred cap002929 { not once ((inv11 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002929c { historically (not (inv11 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002929 { cap002929 iff cap002929c }
check CapBenchEquivalent_cap002929 for 4
