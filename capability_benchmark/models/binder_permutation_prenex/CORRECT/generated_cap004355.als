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

pred cap004355 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((no CapBenchB or some capBenchR) and some capBenchS))) }
pred cap004355c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap004355 { cap004355 iff cap004355c }
check CapBenchEquivalent_cap004355 for 4
