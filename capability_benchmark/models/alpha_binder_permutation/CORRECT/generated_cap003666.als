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
all u:User | all a:Ad | a in u.posts implies u.posts in Ad
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

pred cap003666 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
pred cap003666c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap003666 { cap003666 iff cap003666c }
check CapBenchEquivalent_cap003666 for 4
