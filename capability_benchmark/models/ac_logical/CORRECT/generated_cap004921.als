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

pred cap004921 { not ((inv4 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and no CapBenchA) and some CapBenchB)) }
pred cap004921c { ((not ((no CapBenchA and no CapBenchA) and some CapBenchB)) or (not (inv4 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004921 { cap004921 iff cap004921c }
check CapBenchEquivalent_cap004921 for 4
