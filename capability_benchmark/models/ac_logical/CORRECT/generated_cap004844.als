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

pred inv4 {
no ((Person-Student)-Teacher)
}

pred inv4c {
 Person in Student + Teacher
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004844 { not ((inv4 and ((some CapBenchA and no CapBenchB) or some capBenchS)) and ((some capBenchS or some CapBenchA) or some CapBenchA)) }
pred cap004844c { ((not ((some capBenchS or some CapBenchA) or some CapBenchA)) or (not (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004844 { cap004844 iff cap004844c }
check CapBenchEquivalent_cap004844 for 4
