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

pred cap000137 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchB or some CapBenchB) or no CapBenchA))) }
pred cap000137c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((some CapBenchB or some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000137 { cap000137 iff cap000137c }
check CapBenchEquivalent_cap000137 for 4
