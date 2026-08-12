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
all u:User | all a:Ad | a in u.posts implies u.posts in Ad
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

pred cap002594 { not (((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB))) until (((no CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap002594c { ((not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB))) releases (not ((no CapBenchB or some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002594 { cap002594 iff cap002594c }
check CapBenchEquivalent_cap002594 for 4
