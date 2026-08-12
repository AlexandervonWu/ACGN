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

pred inv8 {
all u: User, a: Ad | a in u.sees => a in u.follows.posts or a in u.suggested.posts
}

pred inv8c {
	all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001351 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap001351c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap001351 { cap001351 iff cap001351c }
check CapBenchEquivalent_cap001351 for 4
