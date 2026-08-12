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
all u:User | some u.posts & Ad implies u.posts in Ad
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

pred cap000003 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap000003c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000003 { cap000003 iff cap000003c }
check CapBenchEquivalent_cap000003 for 4
