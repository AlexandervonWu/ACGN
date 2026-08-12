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

pred cap000844 { (inv3 and ((some CapBenchA and no CapBenchB) or some capBenchS)) }
pred cap000844c { ((inv3 and ((some CapBenchA and no CapBenchB) or some capBenchS)) and (inv3 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000844 { cap000844 iff cap000844c }
check CapBenchEquivalent_cap000844 for 4
