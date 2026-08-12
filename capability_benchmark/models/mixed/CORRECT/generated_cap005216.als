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

pred cap005216 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchA and no CapBenchB) or no CapBenchB)) and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005216c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some CapBenchA and no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005216 { cap005216 iff cap005216c }
check CapBenchEquivalent_cap005216 for 4
