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

pred cap002037 { not ((inv4 and ((some capBenchS or some capBenchR) or some CapBenchA)) and ((no CapBenchA and no CapBenchA) and no CapBenchB)) }
pred cap002037c { ((not (inv4 and ((some capBenchS or some capBenchR) or some CapBenchA))) or (not ((no CapBenchA and no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002037 { cap002037 iff cap002037c }
check CapBenchEquivalent_cap002037 for 4
