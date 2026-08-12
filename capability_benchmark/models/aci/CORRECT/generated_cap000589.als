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
all u : User | all p : Photo | p in u.sees implies p in u.follows.posts or p in Ad
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

pred cap000589 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv3 and ((some CapBenchB or no CapBenchB) or some CapBenchB))) }
pred cap000589c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv3 and ((some CapBenchB or no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000589 { cap000589 iff cap000589c }
check CapBenchEquivalent_cap000589 for 4
