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
all p: Photo - Ad, u1: User | some u2: User | u1->p in sees => u2->p in posts and u1->u2 in follows
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

pred cap001039 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
pred cap001039c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap001039 { cap001039 iff cap001039c }
check CapBenchEquivalent_cap001039 for 4
