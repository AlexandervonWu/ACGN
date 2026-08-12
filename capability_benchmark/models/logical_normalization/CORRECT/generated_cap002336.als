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

pred cap002336 { not not ((inv5 and ((some CapBenchA and no CapBenchA) or some capBenchS))) }
pred cap002336c { (inv5 and ((some CapBenchA and no CapBenchA) or some capBenchS)) }
assert CapBenchEquivalent_cap002336 { cap002336 iff cap002336c }
check CapBenchEquivalent_cap002336 for 4
