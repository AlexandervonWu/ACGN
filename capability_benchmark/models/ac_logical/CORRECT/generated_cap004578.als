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

pred cap004578 { not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
pred cap004578c { ((not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004578 { cap004578 iff cap004578c }
check CapBenchEquivalent_cap004578 for 4
