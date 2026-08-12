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

pred cap002295 { not ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002295c { ((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR))) or (not ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002295 { cap002295 iff cap002295c }
check CapBenchEquivalent_cap002295 for 4
