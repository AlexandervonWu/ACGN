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

pred cap004934 { not ((inv4 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)) }
pred cap004934c { ((not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)) or (not (inv4 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004934 { cap004934 iff cap004934c }
check CapBenchEquivalent_cap004934 for 4
