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

pred cap002362 { ((inv2 and ((no CapBenchA and some capBenchS) and some capBenchS)) implies ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) }
pred cap002362c { ((not (inv2 and ((no CapBenchA and some capBenchS) and some capBenchS))) or ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) }
assert CapBenchEquivalent_cap002362 { cap002362 iff cap002362c }
check CapBenchEquivalent_cap002362 for 4
