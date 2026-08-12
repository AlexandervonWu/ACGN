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
all u:User, p:Photo| p in u.posts and p in Ad implies u.posts in Ad
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

pred cap002639 { not eventually ((inv4 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap002639c { always (not (inv4 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002639 { cap002639 iff cap002639c }
check CapBenchEquivalent_cap002639 for 4
