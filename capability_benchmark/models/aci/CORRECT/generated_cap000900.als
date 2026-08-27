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

pred cap000900 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv7 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000900c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv7 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000900 { cap000900 iff cap000900c }
check CapBenchEquivalent_cap000900 for 4
