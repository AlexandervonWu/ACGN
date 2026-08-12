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

pred cap004991 { not ((inv7 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and no CapBenchB) or no CapBenchA)) }
pred cap004991c { ((not ((some CapBenchA and no CapBenchB) or no CapBenchA)) or (not (inv7 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004991 { cap004991 iff cap004991c }
check CapBenchEquivalent_cap004991 for 4
