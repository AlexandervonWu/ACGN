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

pred inv8 {
all u: User, a: Ad | a in u.sees => a in u.follows.posts or a in u.suggested.posts
}

pred inv8c {
	all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003671 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
pred cap003671c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap003671 { cap003671 iff cap003671c }
check CapBenchEquivalent_cap003671 for 4
