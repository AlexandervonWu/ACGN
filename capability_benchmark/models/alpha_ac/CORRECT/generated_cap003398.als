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

pred cap003398 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
pred cap003398c { all renamed: CapBenchA | (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003398 { cap003398 iff cap003398c }
check CapBenchEquivalent_cap003398 for 4
