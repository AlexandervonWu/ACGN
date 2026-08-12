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

pred inv4 {
all u: User, a: Ad | a in u.posts => u.posts in Ad
}

pred inv4c {
	all u : posts.Ad | u.posts in Ad
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003024 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or some CapBenchA)) and ((some capBenchS or some CapBenchA) or no CapBenchB)) }
pred cap003024c { all renamed: CapBenchA | (((some capBenchS or some CapBenchA) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003024 { cap003024 iff cap003024c }
check CapBenchEquivalent_cap003024 for 4
