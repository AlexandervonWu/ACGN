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

pred cap002452 { ((inv3 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) implies ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap002452c { ((not (inv3 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) or ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
assert CapBenchEquivalent_cap002452 { cap002452 iff cap002452c }
check CapBenchEquivalent_cap002452 for 4
