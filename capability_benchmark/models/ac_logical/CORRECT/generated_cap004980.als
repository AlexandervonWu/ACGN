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

pred cap004980 { not ((inv12 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some CapBenchB) or no CapBenchA)) }
pred cap004980c { ((not ((some capBenchS or some CapBenchB) or no CapBenchA)) or (not (inv12 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004980 { cap004980 iff cap004980c }
check CapBenchEquivalent_cap004980 for 4
