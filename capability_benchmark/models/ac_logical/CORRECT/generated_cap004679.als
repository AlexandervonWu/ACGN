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
all u: User, a: Ad | a in u.posts => u.posts in Ad
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

pred cap004679 { not ((inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) and ((some CapBenchA and some capBenchR) or some capBenchS)) }
pred cap004679c { ((not ((some CapBenchA and some capBenchR) or some capBenchS)) or (not (inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004679 { cap004679 iff cap004679c }
check CapBenchEquivalent_cap004679 for 4
