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

pred cap000860 { ((inv4 and ((some CapBenchA and some capBenchS) or some capBenchS)) and ((some capBenchS or no CapBenchA) or some CapBenchA) and ((no CapBenchB or some CapBenchA) and no CapBenchB)) }
pred cap000860c { (((no CapBenchB or some CapBenchA) and no CapBenchB) and (inv4 and ((some CapBenchA and some capBenchS) or some capBenchS)) and ((some capBenchS or no CapBenchA) or some CapBenchA)) }
assert CapBenchEquivalent_cap000860 { cap000860 iff cap000860c }
check CapBenchEquivalent_cap000860 for 4
