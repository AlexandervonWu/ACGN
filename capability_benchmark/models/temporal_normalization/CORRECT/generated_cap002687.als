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
all p : Photo | p in User.posts
all p : Photo | one u : User | p in u.posts
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

pred cap002687 { not eventually ((inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap002687c { always (not (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002687 { cap002687 iff cap002687c }
check CapBenchEquivalent_cap002687 for 4
