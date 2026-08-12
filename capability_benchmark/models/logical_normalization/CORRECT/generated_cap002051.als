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
all x : User| x.sees- Ad in x.follows.posts
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

pred cap002051 { ((inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) iff ((some CapBenchA and some capBenchR) or no CapBenchB)) }
pred cap002051c { (((not (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) or ((some CapBenchA and some capBenchR) or no CapBenchB)) and ((not ((some CapBenchA and some capBenchR) or no CapBenchB)) or (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)))) }
assert CapBenchEquivalent_cap002051 { cap002051 iff cap002051c }
check CapBenchEquivalent_cap002051 for 4
