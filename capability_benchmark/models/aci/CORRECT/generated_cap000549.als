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
Tutors in (Teacher->Student)
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

pred cap000549 { ((inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB) or ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000549c { (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB) or ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) or (inv13 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap000549 { cap000549 iff cap000549c }
check CapBenchEquivalent_cap000549 for 4
