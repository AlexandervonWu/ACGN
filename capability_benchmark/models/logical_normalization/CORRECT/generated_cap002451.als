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

pred cap002451 { not ((inv8 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap002451c { ((not (inv8 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap002451 { cap002451 iff cap002451c }
check CapBenchEquivalent_cap002451 for 4
