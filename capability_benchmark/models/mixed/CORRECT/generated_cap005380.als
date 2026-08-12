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

pred inv4 {
all u:User | some u.posts & Ad implies u.posts in Ad
}

pred inv4c {
	all u : posts.Ad | u.posts in Ad
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005380 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
pred cap005380c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchS) or some CapBenchA)) or (not (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005380 { cap005380 iff cap005380c }
check CapBenchEquivalent_cap005380 for 4
