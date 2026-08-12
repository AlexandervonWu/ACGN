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
all p : Photo, u1 : User | p not in Ad and u1 -> p in sees implies (some u2 : User | u2 -> p in posts and u1 -> u2 in follows)
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

pred cap004615 { not ((inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((some CapBenchA and some capBenchR) or some capBenchR)) }
pred cap004615c { ((not ((some CapBenchA and some capBenchR) or some capBenchR)) or (not (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004615 { cap004615 iff cap004615c }
check CapBenchEquivalent_cap004615 for 4
