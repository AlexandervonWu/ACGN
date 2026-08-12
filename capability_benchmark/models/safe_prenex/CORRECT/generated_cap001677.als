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
all u : User | u.posts in Ad or no u.posts & Ad
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

pred cap001677 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
pred cap001677c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001677 { cap001677 iff cap001677c }
check CapBenchEquivalent_cap001677 for 4
