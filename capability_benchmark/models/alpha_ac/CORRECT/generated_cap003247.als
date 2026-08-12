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
Class in Teacher.Teaches
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

pred cap003247 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003247c { all renamed: CapBenchA | (((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap003247 { cap003247 iff cap003247c }
check CapBenchEquivalent_cap003247 for 4
