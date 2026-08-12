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
all u1 : User | all ph : Photo |
ph in u1.posts and ph in Ad implies u1.posts in Ad
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

pred cap003482 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) }
pred cap003482c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003482 { cap003482 iff cap003482c }
check CapBenchEquivalent_cap003482 for 4
