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

pred cap004032 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
pred cap004032c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap004032 { cap004032 iff cap004032c }
check CapBenchEquivalent_cap004032 for 4
