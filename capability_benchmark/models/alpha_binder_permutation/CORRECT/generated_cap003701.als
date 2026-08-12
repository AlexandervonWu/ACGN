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

pred inv1 {
all p : Photo | p in User.posts
all p : Photo | one u : User | p in u.posts
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003701 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
pred cap003701c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003701 { cap003701 iff cap003701c }
check CapBenchEquivalent_cap003701 for 4
