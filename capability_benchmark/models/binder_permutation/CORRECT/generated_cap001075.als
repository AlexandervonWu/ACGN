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

pred inv3 {
all u : User | all p : Photo | p in u.sees implies p in u.follows.posts or p in Ad
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001075 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv3 and ((no CapBenchB or some CapBenchB) and some CapBenchB))) }
pred cap001075c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv3 and ((no CapBenchB or some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap001075 { cap001075 iff cap001075c }
check CapBenchEquivalent_cap001075 for 4
