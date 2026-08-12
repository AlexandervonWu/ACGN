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

pred cap002093 { ((inv15 and ((some capBenchS or no CapBenchB) or some CapBenchB)) iff ((no CapBenchA and some CapBenchB) and some capBenchR)) }
pred cap002093c { (((not (inv15 and ((some capBenchS or no CapBenchB) or some CapBenchB))) or ((no CapBenchA and some CapBenchB) and some capBenchR)) and ((not ((no CapBenchA and some CapBenchB) and some capBenchR)) or (inv15 and ((some capBenchS or no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap002093 { cap002093 iff cap002093c }
check CapBenchEquivalent_cap002093 for 4
