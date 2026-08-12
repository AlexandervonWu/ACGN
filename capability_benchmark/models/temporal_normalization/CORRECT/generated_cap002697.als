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

pred cap002697 { not (((inv4 and ((some capBenchS or some CapBenchA) or no CapBenchB))) since (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap002697c { ((not (inv4 and ((some capBenchS or some CapBenchA) or no CapBenchB))) triggered (not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap002697 { cap002697 iff cap002697c }
check CapBenchEquivalent_cap002697 for 4
