sig User {
	follows : set User,
	sees : set Photo,
	posts : set Photo,
	suggested : set User
}

sig Influencer extends User {}

sig Photo {
	date : one Day
}
sig Ad extends Photo {}

sig Day {}

pred inv2 {
all x : User | x not in x.follows
}

pred inv2c {
	all p : User | p not in p.follows
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004697 { not ((inv2 and ((some capBenchS or some CapBenchA) or no CapBenchB)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap004697c { ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) or (not (inv2 and ((some capBenchS or some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004697 { cap004697 iff cap004697c }
check CapBenchEquivalent_cap004697 for 4
