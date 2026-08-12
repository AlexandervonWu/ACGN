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

pred cap004988 { not ((inv4 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or no CapBenchA) or no CapBenchA)) }
pred cap004988c { ((not ((some capBenchS or no CapBenchA) or no CapBenchA)) or (not (inv4 and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004988 { cap004988 iff cap004988c }
check CapBenchEquivalent_cap004988 for 4
