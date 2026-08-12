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
all u : User | u.sees - Ad in u.follows.posts
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

pred cap001133 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv3 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
pred cap001133c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv3 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap001133 { cap001133 iff cap001133c }
check CapBenchEquivalent_cap001133 for 4
