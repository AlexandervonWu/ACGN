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

pred inv8 {
all u:User,a:Ad | a in u.sees implies (some u1:User | a in u1.posts and u1 in u.follows + u.suggested)
}

pred inv8c {
	all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002489 { ((inv8 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) iff ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) }
pred cap002489c { (((not (inv8 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchA)) or (inv8 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap002489 { cap002489 iff cap002489c }
check CapBenchEquivalent_cap002489 for 4
