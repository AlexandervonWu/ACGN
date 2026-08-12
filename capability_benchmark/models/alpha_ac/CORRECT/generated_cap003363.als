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

pred cap003363 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and some capBenchS)) and ((some CapBenchA and no CapBenchB) or some CapBenchA)) }
pred cap003363c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap003363 { cap003363 iff cap003363c }
check CapBenchEquivalent_cap003363 for 4
