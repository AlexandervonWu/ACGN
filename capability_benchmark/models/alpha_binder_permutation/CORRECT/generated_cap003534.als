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
all u:User | all p:Photo | ((p in u.posts) and (p in Ad)) implies u.posts in Ad
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

pred cap003534 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
pred cap003534c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap003534 { cap003534 iff cap003534c }
check CapBenchEquivalent_cap003534 for 4
