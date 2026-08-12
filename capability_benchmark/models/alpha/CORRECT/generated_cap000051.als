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

pred cap000051 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
pred cap000051c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap000051 { cap000051 iff cap000051c }
check CapBenchEquivalent_cap000051 for 4
