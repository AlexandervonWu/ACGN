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

pred inv4 {
all p: Person | p in Teacher or p in Student
}

pred inv4c {
 Person in Student + Teacher
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002866 { not always ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
pred cap002866c { eventually (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap002866 { cap002866 iff cap002866c }
check CapBenchEquivalent_cap002866 for 4
