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

pred cap003010 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchA and some CapBenchB) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap003010c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA) and renamed->renamed in capBenchR and (inv8 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003010 { cap003010 iff cap003010c }
check CapBenchEquivalent_cap003010 for 4
