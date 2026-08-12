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

pred cap002117 { ((inv3 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) iff ((no CapBenchA and some capBenchR) and some capBenchR)) }
pred cap002117c { (((not (inv3 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) or ((no CapBenchA and some capBenchR) and some capBenchR)) and ((not ((no CapBenchA and some capBenchR) and some capBenchR)) or (inv3 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap002117 { cap002117 iff cap002117c }
check CapBenchEquivalent_cap002117 for 4
