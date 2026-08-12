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

pred cap000595 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) }
pred cap000595c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap000595 { cap000595 iff cap000595c }
check CapBenchEquivalent_cap000595 for 4
