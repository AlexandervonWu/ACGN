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

pred cap001102 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
pred cap001102c { all a, b: CapBenchA | (b->a in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap001102 { cap001102 iff cap001102c }
check CapBenchEquivalent_cap001102 for 4
