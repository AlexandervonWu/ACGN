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

pred cap004413 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004413c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004413 { cap004413 iff cap004413c }
check CapBenchEquivalent_cap004413 for 4
