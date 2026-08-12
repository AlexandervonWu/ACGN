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

pred cap002126 { not not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap002126c { (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) }
assert CapBenchEquivalent_cap002126 { cap002126 iff cap002126c }
check CapBenchEquivalent_cap002126 for 4
