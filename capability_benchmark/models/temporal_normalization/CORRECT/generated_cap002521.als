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
all u : User | u.posts in Ad or no u.posts & Ad
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

pred cap002521 { not once ((inv4 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
pred cap002521c { historically (not (inv4 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap002521 { cap002521 iff cap002521c }
check CapBenchEquivalent_cap002521 for 4
