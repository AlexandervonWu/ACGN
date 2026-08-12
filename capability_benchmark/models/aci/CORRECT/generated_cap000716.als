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

pred cap000716 { ((inv11 and ((some CapBenchA and no CapBenchB) or no CapBenchB)) and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
pred cap000716c { (((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA) and (inv11 and ((some CapBenchA and no CapBenchB) or no CapBenchB)) and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000716 { cap000716 iff cap000716c }
check CapBenchEquivalent_cap000716 for 4
