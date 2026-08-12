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

pred cap003261 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or some CapBenchA) or some capBenchR)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003261c { all renamed: CapBenchA | (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003261 { cap003261 iff cap003261c }
check CapBenchEquivalent_cap003261 for 4
