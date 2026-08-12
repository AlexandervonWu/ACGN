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

pred cap000685 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap000685c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000685 { cap000685 iff cap000685c }
check CapBenchEquivalent_cap000685 for 4
