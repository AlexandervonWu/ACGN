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

pred cap000752 { ((inv3 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) }
pred cap000752c { (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB) and (inv3 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000752 { cap000752 iff cap000752c }
check CapBenchEquivalent_cap000752 for 4
