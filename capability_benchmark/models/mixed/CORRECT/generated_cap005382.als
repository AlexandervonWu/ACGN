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
all p:Photo|one u: User| p in u.posts
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

pred cap005382 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
pred cap005382c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some capBenchS) and some CapBenchA)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap005382 { cap005382 iff cap005382c }
check CapBenchEquivalent_cap005382 for 4
