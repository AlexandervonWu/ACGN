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

pred cap002865 { not (((inv7 and ((some capBenchS or some capBenchS) or some capBenchS))) since (((no CapBenchA and no CapBenchB) and some CapBenchA))) }
pred cap002865c { ((not (inv7 and ((some capBenchS or some capBenchS) or some capBenchS))) triggered (not ((no CapBenchA and no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002865 { cap002865 iff cap002865c }
check CapBenchEquivalent_cap002865 for 4
