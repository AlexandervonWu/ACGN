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
all u:User | some u.posts & Ad implies u.posts in Ad
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

pred cap003177 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) }
pred cap003177c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap003177 { cap003177 iff cap003177c }
check CapBenchEquivalent_cap003177 for 4
