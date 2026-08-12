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

pred cap001343 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv12 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap001343c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv12 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap001343 { cap001343 iff cap001343c }
check CapBenchEquivalent_cap001343 for 4
