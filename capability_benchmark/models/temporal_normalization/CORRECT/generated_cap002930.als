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

pred cap002930 { not (((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) until (((no CapBenchB or no CapBenchB) and some CapBenchB))) }
pred cap002930c { ((not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) releases (not ((no CapBenchB or no CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap002930 { cap002930 iff cap002930c }
check CapBenchEquivalent_cap002930 for 4
