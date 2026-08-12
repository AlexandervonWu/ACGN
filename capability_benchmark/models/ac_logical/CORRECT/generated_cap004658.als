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
all u:User | all p:Photo | ((p in u.posts) and (p in Ad)) implies u.posts in Ad
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

pred cap004658 { not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) and ((no CapBenchB or some CapBenchB) and some capBenchS)) }
pred cap004658c { ((not ((no CapBenchB or some CapBenchB) and some capBenchS)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004658 { cap004658 iff cap004658c }
check CapBenchEquivalent_cap004658 for 4
