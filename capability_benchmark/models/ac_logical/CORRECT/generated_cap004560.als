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

pred cap004560 { not ((inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((some CapBenchB or some capBenchS) or no CapBenchB)) }
pred cap004560c { ((not ((some CapBenchB or some capBenchS) or no CapBenchB)) or (not (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004560 { cap004560 iff cap004560c }
check CapBenchEquivalent_cap004560 for 4
