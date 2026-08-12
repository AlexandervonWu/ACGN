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
all u:User, p:Photo| p in u.posts and p in Ad implies u.posts in Ad
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

pred cap004000 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
pred cap004000c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap004000 { cap004000 iff cap004000c }
check CapBenchEquivalent_cap004000 for 4
