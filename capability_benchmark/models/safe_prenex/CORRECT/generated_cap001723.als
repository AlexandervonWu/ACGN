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

pred cap001723 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap001723c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001723 { cap001723 iff cap001723c }
check CapBenchEquivalent_cap001723 for 4
