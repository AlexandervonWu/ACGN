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

pred cap002500 { not always ((inv8 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
pred cap002500c { eventually (not (inv8 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap002500 { cap002500 iff cap002500c }
check CapBenchEquivalent_cap002500 for 4
