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

pred cap002878 { not always ((inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap002878c { eventually (not (inv8 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002878 { cap002878 iff cap002878c }
check CapBenchEquivalent_cap002878 for 4
