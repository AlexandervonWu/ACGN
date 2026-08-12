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

pred inv1 {
all p:Photo| one u:User| u->p in posts
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005366 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) and ((no CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap005366c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchB) and some CapBenchA)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap005366 { cap005366 iff cap005366c }
check CapBenchEquivalent_cap005366 for 4
