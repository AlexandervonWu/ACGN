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

pred inv5 {
some c : Class, p : Person | p -> c in Teaches and p in Teacher
}

pred inv5c {
  some Teacher.Teaches
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001276 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchR and no CapBenchA) or some capBenchR))) }
pred cap001276c { all a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some capBenchR and no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap001276 { cap001276 iff cap001276c }
check CapBenchEquivalent_cap001276 for 4
