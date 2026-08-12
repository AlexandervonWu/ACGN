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

pred cap002716 { not always ((inv8 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
pred cap002716c { eventually (not (inv8 and ((some CapBenchA and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002716 { cap002716 iff cap002716c }
check CapBenchEquivalent_cap002716 for 4
