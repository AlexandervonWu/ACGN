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

pred cap002490 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
pred cap002490c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002490 { cap002490 iff cap002490c }
check CapBenchEquivalent_cap002490 for 4
