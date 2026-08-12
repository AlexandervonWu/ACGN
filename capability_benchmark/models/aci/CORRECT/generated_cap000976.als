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

pred cap000976 { (inv4 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000976c { ((inv4 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and (inv4 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000976 { cap000976 iff cap000976c }
check CapBenchEquivalent_cap000976 for 4
