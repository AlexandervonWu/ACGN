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

pred cap001788 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
pred cap001788c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap001788 { cap001788 iff cap001788c }
check CapBenchEquivalent_cap001788 for 4
