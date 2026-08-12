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

pred cap000999 { ((inv7 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) or ((some CapBenchA and some capBenchR) or no CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)) }
pred cap000999c { (((some CapBenchA and some capBenchR) or no CapBenchA) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS) or (inv7 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000999 { cap000999 iff cap000999c }
check CapBenchEquivalent_cap000999 for 4
