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

pred cap002719 { not once ((inv4 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap002719c { historically (not (inv4 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap002719 { cap002719 iff cap002719c }
check CapBenchEquivalent_cap002719 for 4
