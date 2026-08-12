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
all p: Photo | one u: User| p in u.posts
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

pred cap002229 { not ((inv1 and ((some capBenchS or some capBenchR) or no CapBenchB)) and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002229c { ((not (inv1 and ((some capBenchS or some capBenchR) or no CapBenchB))) or (not ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002229 { cap002229 iff cap002229c }
check CapBenchEquivalent_cap002229 for 4
