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

pred cap002711 { not eventually ((inv4 and ((no CapBenchB or no CapBenchA) and no CapBenchB))) }
pred cap002711c { always (not (inv4 and ((no CapBenchB or no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap002711 { cap002711 iff cap002711c }
check CapBenchEquivalent_cap002711 for 4
