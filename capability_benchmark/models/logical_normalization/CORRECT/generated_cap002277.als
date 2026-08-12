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

pred cap002277 { not ((inv4 and ((some capBenchS or no CapBenchA) or some capBenchR)) and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002277c { ((not (inv4 and ((some capBenchS or no CapBenchA) or some capBenchR))) or (not ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002277 { cap002277 iff cap002277c }
check CapBenchEquivalent_cap002277 for 4
