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
all user : User |
(some user.posts & Ad) implies user.posts & Ad = user.posts
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

pred cap002744 { not (((inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) until (((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002744c { ((not (inv4 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) releases (not ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002744 { cap002744 iff cap002744c }
check CapBenchEquivalent_cap002744 for 4
