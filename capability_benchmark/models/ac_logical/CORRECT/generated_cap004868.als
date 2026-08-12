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
all u:User | u not in follows.u
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

pred cap004868 { not ((inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some capBenchS or no CapBenchB) or some CapBenchA)) }
pred cap004868c { ((not ((some capBenchS or no CapBenchB) or some CapBenchA)) or (not (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap004868 { cap004868 iff cap004868c }
check CapBenchEquivalent_cap004868 for 4
