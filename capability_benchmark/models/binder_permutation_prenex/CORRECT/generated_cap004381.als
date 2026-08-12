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

pred cap004381 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap004381c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap004381 { cap004381 iff cap004381c }
check CapBenchEquivalent_cap004381 for 4
