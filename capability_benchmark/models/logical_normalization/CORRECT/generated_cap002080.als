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
all u : User | u.posts in Ad or u.posts in Photo - Ad
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

pred cap002080 { ((inv4 and ((some CapBenchA and no CapBenchA) or some CapBenchB)) implies ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap002080c { ((not (inv4 and ((some CapBenchA and no CapBenchA) or some CapBenchB))) or ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
assert CapBenchEquivalent_cap002080 { cap002080 iff cap002080c }
check CapBenchEquivalent_cap002080 for 4
