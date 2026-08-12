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

pred cap002146 { ((inv2 and ((no CapBenchA and no CapBenchA) and no CapBenchA)) implies ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap002146c { ((not (inv2 and ((no CapBenchA and no CapBenchA) and no CapBenchA))) or ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
assert CapBenchEquivalent_cap002146 { cap002146 iff cap002146c }
check CapBenchEquivalent_cap002146 for 4
