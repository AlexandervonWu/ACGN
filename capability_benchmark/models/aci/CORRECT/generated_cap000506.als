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

pred inv8 {
all t:Teacher, c1,c2:Class | (t -> c1 in Teaches) and (t -> c2 in Teaches) implies c1 = c2
}

pred inv8c {
  all t:Teacher | lone t.Teaches
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000506 { ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA) and ((some CapBenchB or some capBenchR) or some capBenchS)) }
pred cap000506c { (((some CapBenchB or some capBenchR) or some capBenchS) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
assert CapBenchEquivalent_cap000506 { cap000506 iff cap000506c }
check CapBenchEquivalent_cap000506 for 4
