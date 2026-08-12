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

pred cap003210 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and no CapBenchA) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap003210c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003210 { cap003210 iff cap003210c }
check CapBenchEquivalent_cap003210 for 4
