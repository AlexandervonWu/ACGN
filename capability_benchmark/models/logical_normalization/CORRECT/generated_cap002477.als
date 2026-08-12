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

pred cap002477 { ((inv4 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) iff ((no CapBenchA and some CapBenchB) and no CapBenchA)) }
pred cap002477c { (((not (inv4 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) or ((no CapBenchA and some CapBenchB) and no CapBenchA)) and ((not ((no CapBenchA and some CapBenchB) and no CapBenchA)) or (inv4 and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap002477 { cap002477 iff cap002477c }
check CapBenchEquivalent_cap002477 for 4
