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

pred cap004701 { not ((inv4 and ((some CapBenchB or some CapBenchB) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap004701c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) or (not (inv4 and ((some CapBenchB or some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004701 { cap004701 iff cap004701c }
check CapBenchEquivalent_cap004701 for 4
