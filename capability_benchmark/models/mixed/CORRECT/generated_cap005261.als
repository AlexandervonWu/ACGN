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
all u : User, p : Photo | p in u.sees => p in u.follows.posts or p in Ad
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

pred cap005261 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchS or some CapBenchA) or some capBenchR)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005261c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some capBenchS or some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap005261 { cap005261 iff cap005261c }
check CapBenchEquivalent_cap005261 for 4
