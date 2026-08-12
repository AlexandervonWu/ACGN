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

pred cap005231 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)) and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005231c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005231 { cap005231 iff cap005231c }
check CapBenchEquivalent_cap005231 for 4
