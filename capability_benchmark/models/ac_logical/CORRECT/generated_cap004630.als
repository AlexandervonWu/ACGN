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

pred cap004630 { not ((inv4 and ((no CapBenchA and some CapBenchA) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) }
pred cap004630c { ((not ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchR)) or (not (inv4 and ((no CapBenchA and some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004630 { cap004630 iff cap004630c }
check CapBenchEquivalent_cap004630 for 4
