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

pred cap004920 { not ((inv1 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or no CapBenchA) or some CapBenchB)) }
pred cap004920c { ((not ((some CapBenchB or no CapBenchA) or some CapBenchB)) or (not (inv1 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004920 { cap004920 iff cap004920c }
check CapBenchEquivalent_cap004920 for 4
