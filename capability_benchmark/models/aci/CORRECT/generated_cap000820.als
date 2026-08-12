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

pred inv3 {
no (Teacher & Student)
}

pred inv3c {
 no Student & Teacher 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000820 { (inv3 and ((some CapBenchA and some CapBenchA) or some capBenchS)) }
pred cap000820c { ((inv3 and ((some CapBenchA and some CapBenchA) or some capBenchS)) and (inv3 and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap000820 { cap000820 iff cap000820c }
check CapBenchEquivalent_cap000820 for 4
