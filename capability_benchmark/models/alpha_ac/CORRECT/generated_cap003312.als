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
all u: User | (u.posts in Ad) or (u.posts in Photo-Ad)
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

pred cap003312 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003312c { all renamed: CapBenchA | (((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003312 { cap003312 iff cap003312c }
check CapBenchEquivalent_cap003312 for 4
