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

pred cap002839 { not once ((inv4 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap002839c { historically (not (inv4 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002839 { cap002839 iff cap002839c }
check CapBenchEquivalent_cap002839 for 4
