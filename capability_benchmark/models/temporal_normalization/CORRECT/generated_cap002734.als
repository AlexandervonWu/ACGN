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

pred cap002734 { not always ((inv4 and ((no CapBenchA and some capBenchS) and no CapBenchB))) }
pred cap002734c { eventually (not (inv4 and ((no CapBenchA and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap002734 { cap002734 iff cap002734c }
check CapBenchEquivalent_cap002734 for 4
