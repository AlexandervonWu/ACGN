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

pred cap004561 { not ((inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((no CapBenchA and some capBenchS) and no CapBenchB)) }
pred cap004561c { ((not ((no CapBenchA and some capBenchS) and no CapBenchB)) or (not (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004561 { cap004561 iff cap004561c }
check CapBenchEquivalent_cap004561 for 4
