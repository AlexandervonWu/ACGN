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

pred cap003138 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((no CapBenchA and some CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
pred cap003138c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR) and renamed->renamed in capBenchR and (inv7 and ((no CapBenchA and some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003138 { cap003138 iff cap003138c }
check CapBenchEquivalent_cap003138 for 4
