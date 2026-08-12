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

pred cap001466 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001466c { all a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001466 { cap001466 iff cap001466c }
check CapBenchEquivalent_cap001466 for 4
