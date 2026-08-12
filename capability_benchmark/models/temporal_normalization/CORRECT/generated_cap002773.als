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
all u1 : User | all ph : Photo |
ph in u1.posts and ph in Ad implies u1.posts in Ad
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

pred cap002773 { not once ((inv4 and ((some CapBenchB or no CapBenchA) or some capBenchR))) }
pred cap002773c { historically (not (inv4 and ((some CapBenchB or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002773 { cap002773 iff cap002773c }
check CapBenchEquivalent_cap002773 for 4
