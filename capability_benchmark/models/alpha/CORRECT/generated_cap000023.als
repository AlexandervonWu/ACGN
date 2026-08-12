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
all u : User | u.posts in Ad or u.posts in Photo - Ad
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

pred cap000023 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap000023c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000023 { cap000023 iff cap000023c }
check CapBenchEquivalent_cap000023 for 4
