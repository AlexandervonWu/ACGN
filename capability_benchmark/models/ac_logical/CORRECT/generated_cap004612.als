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

pred cap004612 { not ((inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((some capBenchS or no CapBenchB) or some capBenchR)) }
pred cap004612c { ((not ((some capBenchS or no CapBenchB) or some capBenchR)) or (not (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004612 { cap004612 iff cap004612c }
check CapBenchEquivalent_cap004612 for 4
