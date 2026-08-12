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
all p:Photo|one u: User| p in u.posts
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

pred cap002066 { not not ((inv1 and ((no CapBenchA and some CapBenchA) and some CapBenchB))) }
pred cap002066c { (inv1 and ((no CapBenchA and some CapBenchA) and some CapBenchB)) }
assert CapBenchEquivalent_cap002066 { cap002066 iff cap002066c }
check CapBenchEquivalent_cap002066 for 4
