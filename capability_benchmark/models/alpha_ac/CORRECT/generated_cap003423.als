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

pred cap003423 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchR and no CapBenchA) or some CapBenchB)) }
pred cap003423c { all renamed: CapBenchA | (((some capBenchR and no CapBenchA) or some CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003423 { cap003423 iff cap003423c }
check CapBenchEquivalent_cap003423 for 4
