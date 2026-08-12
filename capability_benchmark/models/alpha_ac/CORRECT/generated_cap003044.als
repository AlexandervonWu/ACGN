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

pred cap003044 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or some CapBenchA)) and ((some CapBenchB or no CapBenchB) or no CapBenchB)) }
pred cap003044c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap003044 { cap003044 iff cap003044c }
check CapBenchEquivalent_cap003044 for 4
