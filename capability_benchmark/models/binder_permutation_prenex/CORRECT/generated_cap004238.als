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

pred cap004238 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
pred cap004238c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap004238 { cap004238 iff cap004238c }
check CapBenchEquivalent_cap004238 for 4
