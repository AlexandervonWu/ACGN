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
all disj t: Teacher | lone t.Teaches
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

pred cap004603 { not ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB)) and ((some capBenchR and no CapBenchA) or some capBenchR)) }
pred cap004603c { ((not ((some capBenchR and no CapBenchA) or some capBenchR)) or (not (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004603 { cap004603 iff cap004603c }
check CapBenchEquivalent_cap004603 for 4
