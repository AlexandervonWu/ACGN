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

pred cap004804 { not ((inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004804c { ((not ((some capBenchS or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)))) }
assert CapBenchEquivalent_cap004804 { cap004804 iff cap004804c }
check CapBenchEquivalent_cap004804 for 4
