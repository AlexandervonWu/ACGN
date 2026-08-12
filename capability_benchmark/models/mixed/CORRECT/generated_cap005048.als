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

pred inv1 {
all p : Photo | p in User.posts
all p : Photo | one u : User | p in u.posts
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005048 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
pred cap005048c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchB) or no CapBenchB)) or (not (inv1 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005048 { cap005048 iff cap005048c }
check CapBenchEquivalent_cap005048 for 4
