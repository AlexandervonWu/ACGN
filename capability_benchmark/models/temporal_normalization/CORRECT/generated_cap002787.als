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

pred cap002787 { not (((inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) since (((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap002787c { ((not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) triggered (not ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002787 { cap002787 iff cap002787c }
check CapBenchEquivalent_cap002787 for 4
