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
all u:User, p:Photo| p in u.posts and p in Ad implies u.posts in Ad
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

pred cap002151 { not ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) and ((some capBenchR and some CapBenchA) or some capBenchS)) }
pred cap002151c { ((not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) or (not ((some capBenchR and some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002151 { cap002151 iff cap002151c }
check CapBenchEquivalent_cap002151 for 4
