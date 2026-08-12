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
all x : Ad | (posts.x).posts in Ad
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

pred cap001493 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv4 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001493c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv4 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001493 { cap001493 iff cap001493c }
check CapBenchEquivalent_cap001493 for 4
