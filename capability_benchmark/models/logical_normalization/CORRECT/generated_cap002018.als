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

pred cap002018 { not not ((inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
pred cap002018c { (inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchA)) }
assert CapBenchEquivalent_cap002018 { cap002018 iff cap002018c }
check CapBenchEquivalent_cap002018 for 4
