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

pred cap000275 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap000275c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000275 { cap000275 iff cap000275c }
check CapBenchEquivalent_cap000275 for 4
