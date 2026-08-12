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

pred cap000554 { ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((no CapBenchB or some capBenchR) and no CapBenchB) and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000554c { (((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((no CapBenchB or some capBenchR) and no CapBenchB)) }
assert CapBenchEquivalent_cap000554 { cap000554 iff cap000554c }
check CapBenchEquivalent_cap000554 for 4
