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

pred cap002095 { no x: CapBenchA | (x->x in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) }
pred cap002095c { all x: CapBenchA | not (x->x in capBenchR and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap002095 { cap002095 iff cap002095c }
check CapBenchEquivalent_cap002095 for 4
