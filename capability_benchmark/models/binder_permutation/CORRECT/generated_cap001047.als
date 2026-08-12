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

pred cap001047 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) }
pred cap001047c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap001047 { cap001047 iff cap001047c }
check CapBenchEquivalent_cap001047 for 4
