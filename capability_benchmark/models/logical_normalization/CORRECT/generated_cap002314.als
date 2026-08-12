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
all u : User | u not in follows.u
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

pred cap002314 { ((inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) implies ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002314c { ((not (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) or ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002314 { cap002314 iff cap002314c }
check CapBenchEquivalent_cap002314 for 4
