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
all u : User | all p : Photo | p in u.sees implies p in u.follows.posts or p in Ad
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

pred cap004598 { not ((inv3 and ((no CapBenchA and some capBenchR) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR)) }
pred cap004598c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR)) or (not (inv3 and ((no CapBenchA and some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004598 { cap004598 iff cap004598c }
check CapBenchEquivalent_cap004598 for 4
