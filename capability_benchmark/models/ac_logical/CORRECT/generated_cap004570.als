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

pred inv2 {
all p:Person | p not in Teacher
}

pred inv2c {
  no Teacher
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004570 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) }
pred cap004570c { ((not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004570 { cap004570 iff cap004570c }
check CapBenchEquivalent_cap004570 for 4
