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
all u:User, a:Ad| u->a in posts implies u.posts in Ad
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

pred cap002205 { not ((inv4 and ((some capBenchS or some CapBenchB) or no CapBenchB)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap002205c { ((not (inv4 and ((some capBenchS or some CapBenchB) or no CapBenchB))) or (not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002205 { cap002205 iff cap002205c }
check CapBenchEquivalent_cap002205 for 4
