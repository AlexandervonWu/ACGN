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

pred inv3 {
all p : Photo, u1 : User | p not in Ad and u1 -> p in sees implies (some u2 : User | u2 -> p in posts and u1 -> u2 in follows)
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003719 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap003719c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003719 { cap003719 iff cap003719c }
check CapBenchEquivalent_cap003719 for 4
