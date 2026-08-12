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
all u : User | some u.posts & Ad implies (u.posts & Ad = u.posts)
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

pred cap004704 { not ((inv4 and ((some capBenchR and some CapBenchB) or no CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap004704c { ((not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv4 and ((some capBenchR and some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004704 { cap004704 iff cap004704c }
check CapBenchEquivalent_cap004704 for 4
