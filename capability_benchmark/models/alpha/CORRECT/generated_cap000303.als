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

pred cap000303 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
pred cap000303c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap000303 { cap000303 iff cap000303c }
check CapBenchEquivalent_cap000303 for 4
