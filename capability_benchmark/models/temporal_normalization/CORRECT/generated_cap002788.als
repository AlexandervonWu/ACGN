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

pred cap002788 { not always ((inv4 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
pred cap002788c { eventually (not (inv4 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap002788 { cap002788 iff cap002788c }
check CapBenchEquivalent_cap002788 for 4
