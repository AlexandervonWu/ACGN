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
all u: User| u not in follows.u
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

pred cap002038 { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) implies ((no CapBenchB or no CapBenchA) and no CapBenchB)) }
pred cap002038c { ((not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) or ((no CapBenchB or no CapBenchA) and no CapBenchB)) }
assert CapBenchEquivalent_cap002038 { cap002038 iff cap002038c }
check CapBenchEquivalent_cap002038 for 4
