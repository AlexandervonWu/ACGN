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

pred cap002862 { not historically ((inv3 and ((no CapBenchA and some capBenchS) and some capBenchS))) }
pred cap002862c { once (not (inv3 and ((no CapBenchA and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap002862 { cap002862 iff cap002862c }
check CapBenchEquivalent_cap002862 for 4
