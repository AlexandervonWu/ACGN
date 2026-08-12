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

pred cap004064 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
pred cap004064c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap004064 { cap004064 iff cap004064c }
check CapBenchEquivalent_cap004064 for 4
