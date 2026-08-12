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

pred cap001909 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001909c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001909 { cap001909 iff cap001909c }
check CapBenchEquivalent_cap001909 for 4
