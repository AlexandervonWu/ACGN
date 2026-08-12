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

pred cap005232 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchA and some capBenchS) or no CapBenchB)) and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005232c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv4 and ((some CapBenchA and some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005232 { cap005232 iff cap005232c }
check CapBenchEquivalent_cap005232 for 4
