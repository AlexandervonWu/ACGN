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
all t:Teacher | lone t.Teaches
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

pred cap000659 { (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) }
pred cap000659c { ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA)) or (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000659 { cap000659 iff cap000659c }
check CapBenchEquivalent_cap000659 for 4
