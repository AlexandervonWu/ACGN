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

pred cap002247 { not ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002247c { ((not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) or (not ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002247 { cap002247 iff cap002247c }
check CapBenchEquivalent_cap002247 for 4
