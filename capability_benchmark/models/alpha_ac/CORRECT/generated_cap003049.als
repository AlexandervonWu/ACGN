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
all u:User, p:Photo| p in u.posts and p in Ad implies u.posts in Ad
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

pred cap003049 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) }
pred cap003049c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap003049 { cap003049 iff cap003049c }
check CapBenchEquivalent_cap003049 for 4
