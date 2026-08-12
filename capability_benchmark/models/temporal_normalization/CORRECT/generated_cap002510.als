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

pred cap002510 { not (((inv4 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) until (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
pred cap002510c { ((not (inv4 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) releases (not ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
assert CapBenchEquivalent_cap002510 { cap002510 iff cap002510c }
check CapBenchEquivalent_cap002510 for 4
