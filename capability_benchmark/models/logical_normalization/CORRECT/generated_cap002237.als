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

pred cap002237 { ((inv3 and ((some capBenchS or some capBenchS) or no CapBenchB)) iff ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002237c { (((not (inv3 and ((some capBenchS or some capBenchS) or no CapBenchB))) or ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((not ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (inv3 and ((some capBenchS or some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap002237 { cap002237 iff cap002237c }
check CapBenchEquivalent_cap002237 for 4
