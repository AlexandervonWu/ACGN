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

pred cap004313 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap004313c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap004313 { cap004313 iff cap004313c }
check CapBenchEquivalent_cap004313 for 4
