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
some c : Class, p : Person | p -> c in Teaches and p in Teacher
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

pred cap002186 { not not ((inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap002186c { (inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
assert CapBenchEquivalent_cap002186 { cap002186 iff cap002186c }
check CapBenchEquivalent_cap002186 for 4
