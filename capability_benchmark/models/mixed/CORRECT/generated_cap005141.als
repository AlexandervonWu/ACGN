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
all u : User | u.sees - Ad in u.follows.posts
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

pred cap005141 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchS or some CapBenchB) or no CapBenchA)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap005141c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) or (not (inv3 and ((some capBenchS or some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005141 { cap005141 iff cap005141c }
check CapBenchEquivalent_cap005141 for 4
