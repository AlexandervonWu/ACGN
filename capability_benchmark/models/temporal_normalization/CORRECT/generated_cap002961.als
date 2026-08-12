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
all u : User | u not in u.follows
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

pred cap002961 { not (((inv2 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) since (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap002961c { ((not (inv2 and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) triggered (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap002961 { cap002961 iff cap002961c }
check CapBenchEquivalent_cap002961 for 4
