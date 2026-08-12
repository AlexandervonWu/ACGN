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

pred cap003858 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
pred cap003858c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap003858 { cap003858 iff cap003858c }
check CapBenchEquivalent_cap003858 for 4
