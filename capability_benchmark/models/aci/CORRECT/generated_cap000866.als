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

pred cap000866 { ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) and ((no CapBenchB or no CapBenchB) and some CapBenchA) and ((some CapBenchB or some CapBenchB) or no CapBenchB)) }
pred cap000866c { (((some CapBenchB or some CapBenchB) or no CapBenchB) and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) and ((no CapBenchB or no CapBenchB) and some CapBenchA)) }
assert CapBenchEquivalent_cap000866 { cap000866 iff cap000866c }
check CapBenchEquivalent_cap000866 for 4
