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

pred cap002518 { not always ((inv7 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
pred cap002518c { eventually (not (inv7 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap002518 { cap002518 iff cap002518c }
check CapBenchEquivalent_cap002518 for 4
