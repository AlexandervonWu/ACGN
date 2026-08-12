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

pred cap001544 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some capBenchR and some capBenchS) or some CapBenchA))) }
pred cap001544c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001544 { cap001544 iff cap001544c }
check CapBenchEquivalent_cap001544 for 4
