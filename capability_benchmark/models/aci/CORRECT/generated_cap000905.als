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

pred inv5 {
some c : Class | some x : Teacher | x->c in Teaches
}

pred inv5c {
  some Teacher.Teaches
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000905 { (inv5 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000905c { ((inv5 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (inv5 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000905 { cap000905 iff cap000905c }
check CapBenchEquivalent_cap000905 for 4
