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

pred cap002765 { not eventually ((inv11 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
pred cap002765c { always (not (inv11 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002765 { cap002765 iff cap002765c }
check CapBenchEquivalent_cap002765 for 4
