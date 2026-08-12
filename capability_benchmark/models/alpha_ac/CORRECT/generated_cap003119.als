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
all x : Ad | (posts.x).posts in Ad
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

pred cap003119 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((some capBenchR and some capBenchR) or some capBenchR)) }
pred cap003119c { all renamed: CapBenchA | (((some capBenchR and some capBenchR) or some capBenchR) and renamed->renamed in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB))) }
assert CapBenchEquivalent_cap003119 { cap003119 iff cap003119c }
check CapBenchEquivalent_cap003119 for 4
