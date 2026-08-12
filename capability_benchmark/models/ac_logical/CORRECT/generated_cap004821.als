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

pred cap004821 { not ((inv4 and ((some CapBenchB or some CapBenchA) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004821c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((some CapBenchB or some CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap004821 { cap004821 iff cap004821c }
check CapBenchEquivalent_cap004821 for 4
