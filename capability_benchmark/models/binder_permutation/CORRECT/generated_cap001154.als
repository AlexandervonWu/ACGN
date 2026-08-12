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

pred cap001154 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
pred cap001154c { all a, b: CapBenchA | (b->a in capBenchR and (inv12 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap001154 { cap001154 iff cap001154c }
check CapBenchEquivalent_cap001154 for 4
