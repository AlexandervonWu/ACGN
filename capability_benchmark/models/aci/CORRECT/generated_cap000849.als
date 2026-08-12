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

pred cap000849 { ((inv4 and ((some capBenchS or no CapBenchB) or some capBenchS)) or ((no CapBenchA and some CapBenchB) and some CapBenchA) or ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap000849c { (((no CapBenchA and some CapBenchB) and some CapBenchA) or ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA) or (inv4 and ((some capBenchS or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000849 { cap000849 iff cap000849c }
check CapBenchEquivalent_cap000849 for 4
