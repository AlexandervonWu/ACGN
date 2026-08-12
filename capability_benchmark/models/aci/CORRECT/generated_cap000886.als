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

pred cap000886 { (inv1 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000886c { ((inv1 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and (inv1 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000886 { cap000886 iff cap000886c }
check CapBenchEquivalent_cap000886 for 4
