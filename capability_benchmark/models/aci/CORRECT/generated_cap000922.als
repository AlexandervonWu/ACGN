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

pred cap000922 { (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000922c { ((inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) and (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000922 { cap000922 iff cap000922c }
check CapBenchEquivalent_cap000922 for 4
