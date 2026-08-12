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

pred cap004128 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv5 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
pred cap004128c { some a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap004128 { cap004128 iff cap004128c }
check CapBenchEquivalent_cap004128 for 4
