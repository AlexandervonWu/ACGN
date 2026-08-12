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

pred cap002230 { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) implies ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002230c { ((not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) or ((no CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002230 { cap002230 iff cap002230c }
check CapBenchEquivalent_cap002230 for 4
