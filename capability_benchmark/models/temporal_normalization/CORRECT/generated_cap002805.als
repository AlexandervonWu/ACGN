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
all u:User, p:Photo | p in Ad and u in posts.p implies (all ph:Photo | u in posts.ph implies ph in Ad)
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

pred cap002805 { not (((inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) since (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002805c { ((not (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002805 { cap002805 iff cap002805c }
check CapBenchEquivalent_cap002805 for 4
