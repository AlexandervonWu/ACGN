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
all u:User, p:Photo | p in Ad and u in posts.p implies (all ph:Photo | u in posts.ph implies ph in Ad)
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

pred cap005029 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or no CapBenchB) or some CapBenchA)) and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
pred cap005029c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchB) and no CapBenchB)) or (not (inv4 and ((some capBenchS or no CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005029 { cap005029 iff cap005029c }
check CapBenchEquivalent_cap005029 for 4
