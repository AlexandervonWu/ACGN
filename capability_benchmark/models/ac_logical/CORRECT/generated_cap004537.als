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
all p: Person | p in Teacher or p in Student
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

pred cap004537 { not ((inv4 and ((some capBenchS or some capBenchR) or some CapBenchA)) and ((no CapBenchA and no CapBenchA) and no CapBenchB)) }
pred cap004537c { ((not ((no CapBenchA and no CapBenchA) and no CapBenchB)) or (not (inv4 and ((some capBenchS or some capBenchR) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004537 { cap004537 iff cap004537c }
check CapBenchEquivalent_cap004537 for 4
