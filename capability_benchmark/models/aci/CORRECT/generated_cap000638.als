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

pred cap000638 { ((inv4 and ((no CapBenchA and some CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR) and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000638c { (((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB) and (inv4 and ((no CapBenchA and some CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
assert CapBenchEquivalent_cap000638 { cap000638 iff cap000638c }
check CapBenchEquivalent_cap000638 for 4
