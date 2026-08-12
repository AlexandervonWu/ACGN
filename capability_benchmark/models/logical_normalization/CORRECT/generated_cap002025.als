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

pred cap002025 { not ((inv3 and ((some CapBenchB or no CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB)) }
pred cap002025c { ((not (inv3 and ((some CapBenchB or no CapBenchB) or some CapBenchA))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002025 { cap002025 iff cap002025c }
check CapBenchEquivalent_cap002025 for 4
