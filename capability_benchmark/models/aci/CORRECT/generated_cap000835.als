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

pred cap000835 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) }
pred cap000835c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000835 { cap000835 iff cap000835c }
check CapBenchEquivalent_cap000835 for 4
