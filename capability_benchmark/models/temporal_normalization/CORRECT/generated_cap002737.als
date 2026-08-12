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

pred cap002737 { not once ((inv4 and ((some capBenchS or some capBenchS) or no CapBenchB))) }
pred cap002737c { historically (not (inv4 and ((some capBenchS or some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap002737 { cap002737 iff cap002737c }
check CapBenchEquivalent_cap002737 for 4
