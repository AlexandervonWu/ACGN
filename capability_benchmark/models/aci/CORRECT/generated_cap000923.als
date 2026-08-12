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

pred cap000923 { (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000923c { ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) or (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000923 { cap000923 iff cap000923c }
check CapBenchEquivalent_cap000923 for 4
