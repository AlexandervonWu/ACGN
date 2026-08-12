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

pred cap002646 { not historically ((inv2 and ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
pred cap002646c { once (not (inv2 and ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap002646 { cap002646 iff cap002646c }
check CapBenchEquivalent_cap002646 for 4
