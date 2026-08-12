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

pred cap004099 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
pred cap004099c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap004099 { cap004099 iff cap004099c }
check CapBenchEquivalent_cap004099 for 4
