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

pred cap000600 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv1 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
pred cap000600c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv1 and ((some capBenchR and some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap000600 { cap000600 iff cap000600c }
check CapBenchEquivalent_cap000600 for 4
