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

pred cap004919 { not ((inv4 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and no CapBenchA) or some CapBenchB)) }
pred cap004919c { ((not ((some CapBenchA and no CapBenchA) or some CapBenchB)) or (not (inv4 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004919 { cap004919 iff cap004919c }
check CapBenchEquivalent_cap004919 for 4
