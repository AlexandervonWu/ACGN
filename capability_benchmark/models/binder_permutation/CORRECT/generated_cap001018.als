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

pred cap001018 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
pred cap001018c { all a, b: CapBenchA | (b->a in capBenchR and (inv12 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap001018 { cap001018 iff cap001018c }
check CapBenchEquivalent_cap001018 for 4
