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

pred cap002429 { ((inv13 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) iff ((no CapBenchA and no CapBenchB) and some CapBenchB)) }
pred cap002429c { (((not (inv13 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) or ((no CapBenchA and no CapBenchB) and some CapBenchB)) and ((not ((no CapBenchA and no CapBenchB) and some CapBenchB)) or (inv13 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap002429 { cap002429 iff cap002429c }
check CapBenchEquivalent_cap002429 for 4
