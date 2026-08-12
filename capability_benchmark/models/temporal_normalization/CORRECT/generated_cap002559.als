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

pred inv1 {
all p : Photo | p in User.posts
all p : Photo | one u : User | p in u.posts
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002559 { not (((inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) since (((some CapBenchA and some capBenchS) or no CapBenchB))) }
pred cap002559c { ((not (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) triggered (not ((some CapBenchA and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap002559 { cap002559 iff cap002559c }
check CapBenchEquivalent_cap002559 for 4
