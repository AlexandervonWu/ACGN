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
all c : Class | (some c.Groups implies some (Teaches.c & Teacher))
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

pred cap004577 { not ((inv11 and ((some capBenchS or some CapBenchB) or some CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
pred cap004577c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) or (not (inv11 and ((some capBenchS or some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004577 { cap004577 iff cap004577c }
check CapBenchEquivalent_cap004577 for 4
