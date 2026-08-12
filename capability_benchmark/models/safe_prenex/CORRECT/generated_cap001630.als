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

pred cap001630 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((no CapBenchA and some CapBenchA) and no CapBenchA))) }
pred cap001630c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001630 { cap001630 iff cap001630c }
check CapBenchEquivalent_cap001630 for 4
