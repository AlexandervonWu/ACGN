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

pred inv15 {
all p:Person | some t:Teacher | t in p.^(~Tutors)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000563 { (inv15 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
pred cap000563c { ((inv15 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) or (inv15 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap000563 { cap000563 iff cap000563c }
check CapBenchEquivalent_cap000563 for 4
