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
all u : User | some u.posts & Ad implies (u.posts & Ad = u.posts)
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

pred cap000155 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap000155c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000155 { cap000155 iff cap000155c }
check CapBenchEquivalent_cap000155 for 4
