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
all u: User | u.sees in (u.follows.posts + Ad)
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

pred cap002410 { ((inv3 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) implies ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) }
pred cap002410c { ((not (inv3 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) or ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) }
assert CapBenchEquivalent_cap002410 { cap002410 iff cap002410c }
check CapBenchEquivalent_cap002410 for 4
