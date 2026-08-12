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
all u : User | u.posts in Ad or u.posts in Photo - Ad
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

pred cap003785 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap003785c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003785 { cap003785 iff cap003785c }
check CapBenchEquivalent_cap003785 for 4
