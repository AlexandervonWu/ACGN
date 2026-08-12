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

pred cap000709 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv13 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
pred cap000709c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv13 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000709 { cap000709 iff cap000709c }
check CapBenchEquivalent_cap000709 for 4
