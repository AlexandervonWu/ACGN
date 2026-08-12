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
all u : User | u.posts in Ad or no u.posts & Ad
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

pred cap000187 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap000187c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000187 { cap000187 iff cap000187c }
check CapBenchEquivalent_cap000187 for 4
