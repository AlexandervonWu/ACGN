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
all u:User, a:Ad| u->a in posts implies u.posts in Ad
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

pred cap003016 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and no CapBenchA) or some CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap003016c { all renamed: CapBenchA | (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003016 { cap003016 iff cap003016c }
check CapBenchEquivalent_cap003016 for 4
