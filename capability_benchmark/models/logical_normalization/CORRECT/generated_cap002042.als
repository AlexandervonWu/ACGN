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

pred cap002042 { not not ((inv4 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap002042c { (inv4 and ((no CapBenchA and some capBenchS) and some CapBenchA)) }
assert CapBenchEquivalent_cap002042 { cap002042 iff cap002042c }
check CapBenchEquivalent_cap002042 for 4
