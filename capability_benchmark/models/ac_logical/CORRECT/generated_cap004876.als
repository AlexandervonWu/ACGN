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

pred cap004876 { not ((inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((some capBenchS or some capBenchR) or some CapBenchA)) }
pred cap004876c { ((not ((some capBenchS or some capBenchR) or some CapBenchA)) or (not (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004876 { cap004876 iff cap004876c }
check CapBenchEquivalent_cap004876 for 4
