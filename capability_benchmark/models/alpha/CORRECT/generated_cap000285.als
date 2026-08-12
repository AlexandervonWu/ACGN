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

pred cap000285 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap000285c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000285 { cap000285 iff cap000285c }
check CapBenchEquivalent_cap000285 for 4
