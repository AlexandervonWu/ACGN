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

pred cap001112 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap001112c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap001112 { cap001112 iff cap001112c }
check CapBenchEquivalent_cap001112 for 4
