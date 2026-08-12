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
all u: User | (u.posts in Ad) or (u.posts in Photo-Ad)
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

pred cap004371 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap004371c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap004371 { cap004371 iff cap004371c }
check CapBenchEquivalent_cap004371 for 4
