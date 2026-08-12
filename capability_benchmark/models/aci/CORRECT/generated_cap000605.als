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

pred cap000605 { (inv4 and ((some CapBenchB or some capBenchS) or some CapBenchB)) }
pred cap000605c { ((inv4 and ((some CapBenchB or some capBenchS) or some CapBenchB)) or (inv4 and ((some CapBenchB or some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap000605 { cap000605 iff cap000605c }
check CapBenchEquivalent_cap000605 for 4
