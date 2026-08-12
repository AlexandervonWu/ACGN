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

pred cap000457 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000457c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000457 { cap000457 iff cap000457c }
check CapBenchEquivalent_cap000457 for 4
