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

pred cap002422 { ((inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) implies ((no CapBenchB or no CapBenchA) and some CapBenchB)) }
pred cap002422c { ((not (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) or ((no CapBenchB or no CapBenchA) and some CapBenchB)) }
assert CapBenchEquivalent_cap002422 { cap002422 iff cap002422c }
check CapBenchEquivalent_cap002422 for 4
