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

pred cap000951 { ((inv5 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)) }
pred cap000951c { (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR) or (inv5 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000951 { cap000951 iff cap000951c }
check CapBenchEquivalent_cap000951 for 4
