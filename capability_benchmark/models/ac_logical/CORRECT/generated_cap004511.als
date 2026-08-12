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
all user : User |
(some user.posts & Ad) implies user.posts & Ad = user.posts
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

pred cap004511 { not ((inv4 and ((no CapBenchB or some CapBenchB) and some CapBenchA)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap004511c { ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) or (not (inv4 and ((no CapBenchB or some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004511 { cap004511 iff cap004511c }
check CapBenchEquivalent_cap004511 for 4
