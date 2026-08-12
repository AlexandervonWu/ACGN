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

pred cap004082 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
pred cap004082c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap004082 { cap004082 iff cap004082c }
check CapBenchEquivalent_cap004082 for 4
