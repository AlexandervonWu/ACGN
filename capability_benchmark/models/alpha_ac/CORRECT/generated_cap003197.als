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

pred inv1 {
all p:Person | p in Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003197 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or no CapBenchB)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap003197c { all renamed: CapBenchA | (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003197 { cap003197 iff cap003197c }
check CapBenchEquivalent_cap003197 for 4
