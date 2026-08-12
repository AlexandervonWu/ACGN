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

pred inv15 {
all p:Person | some (^Tutors.p & Teacher)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004572 { not ((inv15 and ((some CapBenchA and some CapBenchB) or some CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap004572c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) or (not (inv15 and ((some CapBenchA and some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004572 { cap004572 iff cap004572c }
check CapBenchEquivalent_cap004572 for 4
