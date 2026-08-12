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
all x : Photo | one posts.x
all x : Photo | one posts.x
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

pred cap002841 { not (((inv1 and ((some capBenchS or no CapBenchA) or some capBenchS))) since (((no CapBenchA and some CapBenchA) and some CapBenchA))) }
pred cap002841c { ((not (inv1 and ((some capBenchS or no CapBenchA) or some capBenchS))) triggered (not ((no CapBenchA and some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap002841 { cap002841 iff cap002841c }
check CapBenchEquivalent_cap002841 for 4
