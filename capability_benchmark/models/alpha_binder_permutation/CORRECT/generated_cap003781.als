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

pred cap003781 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
pred cap003781c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003781 { cap003781 iff cap003781c }
check CapBenchEquivalent_cap003781 for 4
