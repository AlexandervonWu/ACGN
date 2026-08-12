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

pred cap002363 { ((inv8 and ((no CapBenchB or some capBenchS) and some capBenchS)) iff ((some CapBenchA and no CapBenchB) or some CapBenchA)) }
pred cap002363c { (((not (inv8 and ((no CapBenchB or some capBenchS) and some capBenchS))) or ((some CapBenchA and no CapBenchB) or some CapBenchA)) and ((not ((some CapBenchA and no CapBenchB) or some CapBenchA)) or (inv8 and ((no CapBenchB or some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap002363 { cap002363 iff cap002363c }
check CapBenchEquivalent_cap002363 for 4
