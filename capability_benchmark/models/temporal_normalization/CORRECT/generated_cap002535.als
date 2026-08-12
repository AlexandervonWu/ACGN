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
all p:Photo| one u:User| u->p in posts
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

pred cap002535 { not (((inv1 and ((no CapBenchB or some capBenchR) and some CapBenchA))) since (((some CapBenchA and no CapBenchA) or no CapBenchB))) }
pred cap002535c { ((not (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchA))) triggered (not ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap002535 { cap002535 iff cap002535c }
check CapBenchEquivalent_cap002535 for 4
