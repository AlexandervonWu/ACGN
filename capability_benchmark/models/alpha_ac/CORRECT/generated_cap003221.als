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

pred cap003221 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some capBenchS or no CapBenchB) or no CapBenchB)) and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003221c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv5 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003221 { cap003221 iff cap003221c }
check CapBenchEquivalent_cap003221 for 4
