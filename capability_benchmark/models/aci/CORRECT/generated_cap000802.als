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

pred cap000802 { (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) }
pred cap000802c { ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR)) and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap000802 { cap000802 iff cap000802c }
check CapBenchEquivalent_cap000802 for 4
