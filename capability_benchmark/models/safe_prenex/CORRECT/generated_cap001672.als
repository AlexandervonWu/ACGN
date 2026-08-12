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

pred cap001672 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
pred cap001672c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001672 { cap001672 iff cap001672c }
check CapBenchEquivalent_cap001672 for 4
