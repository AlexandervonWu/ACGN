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

pred cap004304 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap004304c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap004304 { cap004304 iff cap004304c }
check CapBenchEquivalent_cap004304 for 4
