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
all p:Photo|one u: User| p in u.posts
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

pred cap002541 { not (((inv1 and ((some CapBenchB or some capBenchS) or some CapBenchA))) since (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
pred cap002541c { ((not (inv1 and ((some CapBenchB or some capBenchS) or some CapBenchA))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002541 { cap002541 iff cap002541c }
check CapBenchEquivalent_cap002541 for 4
