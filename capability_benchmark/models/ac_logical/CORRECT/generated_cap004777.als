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

pred cap004777 { not ((inv12 and ((some capBenchS or no CapBenchA) or some capBenchR)) and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004777c { ((not ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv12 and ((some capBenchS or no CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap004777 { cap004777 iff cap004777c }
check CapBenchEquivalent_cap004777 for 4
