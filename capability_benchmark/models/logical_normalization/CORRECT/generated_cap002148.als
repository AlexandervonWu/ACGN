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

pred cap002148 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA)))) }
pred cap002148c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002148 { cap002148 iff cap002148c }
check CapBenchEquivalent_cap002148 for 4
