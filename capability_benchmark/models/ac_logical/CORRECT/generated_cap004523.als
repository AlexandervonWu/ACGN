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

pred cap004523 { not ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) and ((some capBenchR and some CapBenchA) or no CapBenchB)) }
pred cap004523c { ((not ((some capBenchR and some CapBenchA) or no CapBenchB)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004523 { cap004523 iff cap004523c }
check CapBenchEquivalent_cap004523 for 4
