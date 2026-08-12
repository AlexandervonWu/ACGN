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

pred cap004714 { not ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)) and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004714c { ((not ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004714 { cap004714 iff cap004714c }
check CapBenchEquivalent_cap004714 for 4
