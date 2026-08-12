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
all u:User | some u.posts & Ad implies u.posts in Ad
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

pred cap004464 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004464c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004464 { cap004464 iff cap004464c }
check CapBenchEquivalent_cap004464 for 4
