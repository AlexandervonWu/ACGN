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
Teaches.Groups.Group.Person & Teacher = Teacher
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

pred cap004842 { not ((inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) and ((no CapBenchB or some CapBenchA) and some CapBenchA)) }
pred cap004842c { ((not ((no CapBenchB or some CapBenchA) and some CapBenchA)) or (not (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap004842 { cap004842 iff cap004842c }
check CapBenchEquivalent_cap004842 for 4
