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
all x : User| x.sees- Ad in x.follows.posts
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

pred cap005298 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchA and some capBenchS) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005298c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv3 and ((no CapBenchA and some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap005298 { cap005298 iff cap005298c }
check CapBenchEquivalent_cap005298 for 4
