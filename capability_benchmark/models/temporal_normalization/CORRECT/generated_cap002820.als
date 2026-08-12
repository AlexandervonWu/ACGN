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

pred cap002820 { not historically ((inv4 and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
pred cap002820c { once (not (inv4 and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002820 { cap002820 iff cap002820c }
check CapBenchEquivalent_cap002820 for 4
