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

pred inv1 {
all u:User,u2:User | all p:Photo | p in u.posts and p in u2.posts implies u = u2
all p:Photo | p in User.posts
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004848 { not ((inv1 and ((some capBenchR and no CapBenchB) or some capBenchS)) and ((some CapBenchB or some CapBenchB) or some CapBenchA)) }
pred cap004848c { ((not ((some CapBenchB or some CapBenchB) or some CapBenchA)) or (not (inv1 and ((some capBenchR and no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004848 { cap004848 iff cap004848c }
check CapBenchEquivalent_cap004848 for 4
