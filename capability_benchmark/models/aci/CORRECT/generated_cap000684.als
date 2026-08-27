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

pred cap000684 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap000684c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv8 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000684 { cap000684 iff cap000684c }
check CapBenchEquivalent_cap000684 for 4
