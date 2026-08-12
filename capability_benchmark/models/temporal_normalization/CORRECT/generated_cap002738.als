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

pred cap002738 { not (((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) until (((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002738c { ((not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) releases (not ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002738 { cap002738 iff cap002738c }
check CapBenchEquivalent_cap002738 for 4
