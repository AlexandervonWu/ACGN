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

pred cap000703 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv8 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap000703c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv8 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000703 { cap000703 iff cap000703c }
check CapBenchEquivalent_cap000703 for 4
