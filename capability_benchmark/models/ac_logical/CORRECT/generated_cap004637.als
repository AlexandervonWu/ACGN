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

pred inv3 {
all u: User | u.sees in (u.follows.posts + Ad)
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004637 { not ((inv3 and ((some CapBenchB or some CapBenchB) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) }
pred cap004637c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) or (not (inv3 and ((some CapBenchB or some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004637 { cap004637 iff cap004637c }
check CapBenchEquivalent_cap004637 for 4
