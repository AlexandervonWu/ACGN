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

pred cap004852 { not ((inv4 and ((some CapBenchA and some capBenchR) or some capBenchS)) and ((some capBenchS or some CapBenchB) or some CapBenchA)) }
pred cap004852c { ((not ((some capBenchS or some CapBenchB) or some CapBenchA)) or (not (inv4 and ((some CapBenchA and some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap004852 { cap004852 iff cap004852c }
check CapBenchEquivalent_cap004852 for 4
