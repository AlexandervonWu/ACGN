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

pred inv7 {
all c : Class | some (Teaches.c & Teacher)
}

pred inv7c {
  all c:Class | some Teacher&Teaches.c
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000632 { ((inv7 and ((some capBenchR and some CapBenchA) or no CapBenchA)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000632c { (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and (inv7 and ((some capBenchR and some CapBenchA) or no CapBenchA)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
assert CapBenchEquivalent_cap000632 { cap000632 iff cap000632c }
check CapBenchEquivalent_cap000632 for 4
