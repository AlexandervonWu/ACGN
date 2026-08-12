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

pred cap000909 { ((inv15 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap000909c { (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) or (inv15 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000909 { cap000909 iff cap000909c }
check CapBenchEquivalent_cap000909 for 4
