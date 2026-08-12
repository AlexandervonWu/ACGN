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

pred cap004735 { not ((inv8 and ((no CapBenchB or some capBenchS) and no CapBenchB)) and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004735c { ((not ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((no CapBenchB or some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004735 { cap004735 iff cap004735c }
check CapBenchEquivalent_cap004735 for 4
