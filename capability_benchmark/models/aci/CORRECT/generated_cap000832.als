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

pred cap000832 { (inv8 and ((some capBenchR and some CapBenchB) or some capBenchS)) }
pred cap000832c { ((inv8 and ((some capBenchR and some CapBenchB) or some capBenchS)) and (inv8 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000832 { cap000832 iff cap000832c }
check CapBenchEquivalent_cap000832 for 4
