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
all u:User,a:Ad | a in u.sees implies (some u1:User | a in u1.posts and u1 in u.follows + u.suggested)
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

pred cap001165 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv8 and ((some capBenchS or some capBenchR) or no CapBenchA))) }
pred cap001165c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv8 and ((some capBenchS or some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap001165 { cap001165 iff cap001165c }
check CapBenchEquivalent_cap001165 for 4
