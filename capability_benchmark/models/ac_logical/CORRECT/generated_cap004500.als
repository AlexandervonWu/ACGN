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
all u:User | all p:Photo | ((p in u.posts) and (p in Ad)) implies u.posts in Ad
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

pred cap004500 { not ((inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchA)) and ((some capBenchS or some capBenchS) or no CapBenchA)) }
pred cap004500c { ((not ((some capBenchS or some capBenchS) or no CapBenchA)) or (not (inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004500 { cap004500 iff cap004500c }
check CapBenchEquivalent_cap004500 for 4
