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

pred cap000635 { (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)) }
pred cap000635c { ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap000635 { cap000635 iff cap000635c }
check CapBenchEquivalent_cap000635 for 4
