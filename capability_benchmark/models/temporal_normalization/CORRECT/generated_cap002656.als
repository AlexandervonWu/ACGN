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

pred cap002656 { not always ((inv1 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
pred cap002656c { eventually (not (inv1 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002656 { cap002656 iff cap002656c }
check CapBenchEquivalent_cap002656 for 4
