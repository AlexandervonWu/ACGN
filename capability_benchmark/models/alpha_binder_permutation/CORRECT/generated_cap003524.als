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
all p: Photo | one u: User| p in u.posts
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

pred cap003524 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and no CapBenchB) or some CapBenchA))) }
pred cap003524c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchA and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003524 { cap003524 iff cap003524c }
check CapBenchEquivalent_cap003524 for 4
