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
all u:User, p:Photo| p in u.posts and p in Ad implies u.posts in Ad
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

pred cap001113 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap001113c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap001113 { cap001113 iff cap001113c }
check CapBenchEquivalent_cap001113 for 4
