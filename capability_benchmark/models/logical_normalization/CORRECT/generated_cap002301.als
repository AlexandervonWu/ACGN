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

pred cap002301 { not ((inv3 and ((some capBenchS or some capBenchS) or some capBenchR)) and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002301c { ((not (inv3 and ((some capBenchS or some capBenchS) or some capBenchR))) or (not ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002301 { cap002301 iff cap002301c }
check CapBenchEquivalent_cap002301 for 4
