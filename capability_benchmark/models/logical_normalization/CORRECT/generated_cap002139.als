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

pred cap002139 { not ((inv3 and ((no CapBenchB or some CapBenchB) and no CapBenchA)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap002139c { ((not (inv3 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002139 { cap002139 iff cap002139c }
check CapBenchEquivalent_cap002139 for 4
