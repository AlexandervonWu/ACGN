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

pred cap001557 { ((all x: CapBenchA | x->x in capBenchR) or (inv12 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap001557c { (all x: CapBenchA | (x->x in capBenchR or (inv12 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001557 { cap001557 iff cap001557c }
check CapBenchEquivalent_cap001557 for 4
