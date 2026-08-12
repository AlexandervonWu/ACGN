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
all u: User, a: Ad | a in u.sees => a in u.follows.posts or a in u.suggested.posts
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

pred cap004981 { not ((inv8 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA)) }
pred cap004981c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA)) or (not (inv8 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004981 { cap004981 iff cap004981c }
check CapBenchEquivalent_cap004981 for 4
