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
all x : User | x not in x.follows
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

pred cap002574 { not historically ((inv2 and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
pred cap002574c { once (not (inv2 and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap002574 { cap002574 iff cap002574c }
check CapBenchEquivalent_cap002574 for 4
