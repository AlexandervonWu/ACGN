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
all u : User | u.posts in Ad or no u.posts & Ad
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

pred cap001248 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap001248c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap001248 { cap001248 iff cap001248c }
check CapBenchEquivalent_cap001248 for 4
