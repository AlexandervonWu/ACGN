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
all p : Photo, u1 : User | p not in Ad and u1 -> p in sees implies (some u2 : User | u2 -> p in posts and u1 -> u2 in follows)
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

pred cap000481 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000481c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000481 { cap000481 iff cap000481c }
check CapBenchEquivalent_cap000481 for 4
