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
all x : Ad | (posts.x).posts in Ad
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

pred cap002732 { not (((inv4 and ((some CapBenchA and some capBenchS) or no CapBenchB))) until (((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002732c { ((not (inv4 and ((some CapBenchA and some capBenchS) or no CapBenchB))) releases (not ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002732 { cap002732 iff cap002732c }
check CapBenchEquivalent_cap002732 for 4
