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

pred cap004664 { not ((inv4 and ((some capBenchR and some capBenchR) or no CapBenchA)) and ((some CapBenchB or no CapBenchA) or some capBenchS)) }
pred cap004664c { ((not ((some CapBenchB or no CapBenchA) or some capBenchS)) or (not (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004664 { cap004664 iff cap004664c }
check CapBenchEquivalent_cap004664 for 4
