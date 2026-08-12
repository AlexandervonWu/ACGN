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
all u : User | u.sees - Ad in u.follows.posts
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

pred cap004641 { not ((inv3 and ((some capBenchS or some CapBenchB) or no CapBenchA)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) }
pred cap004641c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) or (not (inv3 and ((some capBenchS or some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004641 { cap004641 iff cap004641c }
check CapBenchEquivalent_cap004641 for 4
