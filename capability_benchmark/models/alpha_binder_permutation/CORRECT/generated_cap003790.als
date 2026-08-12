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

pred inv4 {
all u : User | u.posts in Ad or no u.posts & Ad
}

pred inv4c {
	all u : posts.Ad | u.posts in Ad
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003790 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
pred cap003790c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap003790 { cap003790 iff cap003790c }
check CapBenchEquivalent_cap003790 for 4
