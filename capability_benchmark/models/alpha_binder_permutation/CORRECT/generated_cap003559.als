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
all x : Ad | (posts.x).posts in Ad
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

pred cap003559 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
pred cap003559c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003559 { cap003559 iff cap003559c }
check CapBenchEquivalent_cap003559 for 4
