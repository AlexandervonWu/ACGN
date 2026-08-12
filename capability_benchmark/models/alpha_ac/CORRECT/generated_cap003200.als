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

pred cap003200 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchA and some CapBenchB) or no CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap003200c { all renamed: CapBenchA | (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS) and renamed->renamed in capBenchR and (inv7 and ((some CapBenchA and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003200 { cap003200 iff cap003200c }
check CapBenchEquivalent_cap003200 for 4
