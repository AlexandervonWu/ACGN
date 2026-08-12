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

pred cap001280 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
pred cap001280c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap001280 { cap001280 iff cap001280c }
check CapBenchEquivalent_cap001280 for 4
