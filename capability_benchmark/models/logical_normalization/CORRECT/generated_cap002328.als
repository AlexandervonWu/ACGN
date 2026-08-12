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
all u: User, a: Ad | a in u.posts => u.posts in Ad
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

pred cap002328 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or some capBenchS)))) }
pred cap002328c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002328 { cap002328 iff cap002328c }
check CapBenchEquivalent_cap002328 for 4
