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

pred cap002872 { not always ((inv11 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap002872c { eventually (not (inv11 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap002872 { cap002872 iff cap002872c }
check CapBenchEquivalent_cap002872 for 4
