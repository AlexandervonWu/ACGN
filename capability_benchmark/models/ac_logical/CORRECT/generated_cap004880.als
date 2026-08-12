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
all u:User | all p:Photo | ((p in u.posts) and (p in Ad)) implies u.posts in Ad
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

pred cap004880 { not ((inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((some CapBenchB or some capBenchS) or some CapBenchA)) }
pred cap004880c { ((not ((some CapBenchB or some capBenchS) or some CapBenchA)) or (not (inv4 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004880 { cap004880 iff cap004880c }
check CapBenchEquivalent_cap004880 for 4
