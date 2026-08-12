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

pred inv13 {
all p1,p2:Person | p2 in p1.Tutors implies p1 in Teacher and p2 in Student
}

pred inv13c {
  Tutors in Teacher -> Student
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004497 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004497c { some a, b: CapBenchA | (b->a in capBenchR and (inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004497 { cap004497 iff cap004497c }
check CapBenchEquivalent_cap004497 for 4
