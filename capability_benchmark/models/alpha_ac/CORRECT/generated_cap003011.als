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
some c : Class | some x : Teacher | x->c in Teaches
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

pred cap003011 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and some CapBenchA)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap003011c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003011 { cap003011 iff cap003011c }
check CapBenchEquivalent_cap003011 for 4
