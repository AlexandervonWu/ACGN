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

pred inv12 {
all t : Teacher | some t.Teaches.Groups
}

pred inv12c {
 all x:Teacher | some x.Teaches.Groups
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004780 { not ((inv12 and ((some CapBenchA and no CapBenchB) or some capBenchR)) and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004780c { ((not ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv12 and ((some CapBenchA and no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004780 { cap004780 iff cap004780c }
check CapBenchEquivalent_cap004780 for 4
