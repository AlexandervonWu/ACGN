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

pred cap002122 { ((inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) implies ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) }
pred cap002122c { ((not (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) or ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) }
assert CapBenchEquivalent_cap002122 { cap002122 iff cap002122c }
check CapBenchEquivalent_cap002122 for 4
