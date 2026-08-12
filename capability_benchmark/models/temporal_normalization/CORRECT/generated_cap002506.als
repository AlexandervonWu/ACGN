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

pred cap002506 { not always ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA))) }
pred cap002506c { eventually (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap002506 { cap002506 iff cap002506c }
check CapBenchEquivalent_cap002506 for 4
