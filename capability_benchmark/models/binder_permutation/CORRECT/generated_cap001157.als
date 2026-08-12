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

pred cap001157 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv8 and ((some capBenchS or no CapBenchB) or no CapBenchA))) }
pred cap001157c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv8 and ((some capBenchS or no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap001157 { cap001157 iff cap001157c }
check CapBenchEquivalent_cap001157 for 4
