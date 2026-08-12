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
all u: User | (u.posts in Ad) or (u.posts in Photo-Ad)
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

pred cap003521 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
pred cap003521c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003521 { cap003521 iff cap003521c }
check CapBenchEquivalent_cap003521 for 4
