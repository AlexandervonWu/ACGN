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

pred cap000689 { (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap000689c { ((inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) or (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000689 { cap000689 iff cap000689c }
check CapBenchEquivalent_cap000689 for 4
