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

pred cap005495 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
pred cap005495c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchB) or no CapBenchA)) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005495 { cap005495 iff cap005495c }
check CapBenchEquivalent_cap005495 for 4
