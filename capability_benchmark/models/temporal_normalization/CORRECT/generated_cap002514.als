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

pred cap002514 { not historically ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
pred cap002514c { once (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002514 { cap002514 iff cap002514c }
check CapBenchEquivalent_cap002514 for 4
