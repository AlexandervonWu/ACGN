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
all u:User, p:Photo| p in u.posts and p in Ad implies u.posts in Ad
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

pred cap002421 { not ((inv4 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and no CapBenchA) and some CapBenchB)) }
pred cap002421c { ((not (inv4 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) or (not ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002421 { cap002421 iff cap002421c }
check CapBenchEquivalent_cap002421 for 4
