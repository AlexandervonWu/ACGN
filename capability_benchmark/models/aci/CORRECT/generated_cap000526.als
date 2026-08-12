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
no (posts.Ad & posts.(Photo-Ad))
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

pred cap000526 { (inv4 and ((no CapBenchA and no CapBenchB) and some CapBenchA)) }
pred cap000526c { ((inv4 and ((no CapBenchA and no CapBenchB) and some CapBenchA)) and (inv4 and ((no CapBenchA and no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap000526 { cap000526 iff cap000526c }
check CapBenchEquivalent_cap000526 for 4
