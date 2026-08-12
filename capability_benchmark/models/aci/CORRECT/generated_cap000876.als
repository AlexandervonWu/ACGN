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

pred cap000876 { (some ((CapBenchA.capBenchR).capBenchR) and (inv5 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap000876c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv5 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000876 { cap000876 iff cap000876c }
check CapBenchEquivalent_cap000876 for 4
