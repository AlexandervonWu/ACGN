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
all u : User | some u.posts & Ad implies (u.posts & Ad = u.posts)
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

pred cap004200 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some CapBenchA and some CapBenchB) or no CapBenchB))) }
pred cap004200c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap004200 { cap004200 iff cap004200c }
check CapBenchEquivalent_cap004200 for 4
