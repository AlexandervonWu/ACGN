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

pred cap002586 { not historically ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
pred cap002586c { once (not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002586 { cap002586 iff cap002586c }
check CapBenchEquivalent_cap002586 for 4
