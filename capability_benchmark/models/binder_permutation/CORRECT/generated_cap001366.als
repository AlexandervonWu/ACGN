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
no (posts.Ad & posts.(Photo-Ad))
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

pred cap001366 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
pred cap001366c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap001366 { cap001366 iff cap001366c }
check CapBenchEquivalent_cap001366 for 4
