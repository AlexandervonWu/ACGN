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
all u:User | u not in u.follows
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

pred cap004705 { not ((inv2 and ((some capBenchS or some CapBenchB) or no CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap004705c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) or (not (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004705 { cap004705 iff cap004705c }
check CapBenchEquivalent_cap004705 for 4
