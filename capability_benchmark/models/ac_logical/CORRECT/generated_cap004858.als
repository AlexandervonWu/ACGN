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
all x : Ad | (posts.x).posts in Ad
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

pred cap004858 { not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)) and ((no CapBenchB or no CapBenchA) and some CapBenchA)) }
pred cap004858c { ((not ((no CapBenchB or no CapBenchA) and some CapBenchA)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap004858 { cap004858 iff cap004858c }
check CapBenchEquivalent_cap004858 for 4
