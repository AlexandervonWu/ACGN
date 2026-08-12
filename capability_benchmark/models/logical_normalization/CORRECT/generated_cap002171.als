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

pred cap002171 { ((inv3 and ((no CapBenchB or some capBenchS) and no CapBenchA)) iff ((some CapBenchA and no CapBenchB) or some capBenchS)) }
pred cap002171c { (((not (inv3 and ((no CapBenchB or some capBenchS) and no CapBenchA))) or ((some CapBenchA and no CapBenchB) or some capBenchS)) and ((not ((some CapBenchA and no CapBenchB) or some capBenchS)) or (inv3 and ((no CapBenchB or some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap002171 { cap002171 iff cap002171c }
check CapBenchEquivalent_cap002171 for 4
