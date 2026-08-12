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

pred cap004222 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
pred cap004222c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap004222 { cap004222 iff cap004222c }
check CapBenchEquivalent_cap004222 for 4
