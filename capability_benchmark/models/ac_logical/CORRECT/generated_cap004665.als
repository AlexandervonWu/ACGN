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
all u:User | all a:Ad | a in u.posts implies u.posts in Ad
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

pred cap004665 { not ((inv4 and ((some capBenchS or some capBenchR) or no CapBenchA)) and ((no CapBenchA and no CapBenchA) and some capBenchS)) }
pred cap004665c { ((not ((no CapBenchA and no CapBenchA) and some capBenchS)) or (not (inv4 and ((some capBenchS or some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004665 { cap004665 iff cap004665c }
check CapBenchEquivalent_cap004665 for 4
