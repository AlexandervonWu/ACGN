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

pred cap001869 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap001869c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap001869 { cap001869 iff cap001869c }
check CapBenchEquivalent_cap001869 for 4
