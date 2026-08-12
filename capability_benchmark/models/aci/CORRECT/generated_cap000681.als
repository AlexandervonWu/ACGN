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

pred inv5 {
some Teacher.Teaches
}

pred inv5c {
  some Teacher.Teaches
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000681 { ((inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) or ((no CapBenchA and some capBenchR) and some capBenchS) or ((some CapBenchA and no CapBenchA) or some CapBenchA)) }
pred cap000681c { (((no CapBenchA and some capBenchR) and some capBenchS) or ((some CapBenchA and no CapBenchA) or some CapBenchA) or (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap000681 { cap000681 iff cap000681c }
check CapBenchEquivalent_cap000681 for 4
