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

pred cap003392 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap003392c { all renamed: CapBenchA | (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003392 { cap003392 iff cap003392c }
check CapBenchEquivalent_cap003392 for 4
