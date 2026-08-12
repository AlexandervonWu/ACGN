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

pred cap001262 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
pred cap001262c { all a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap001262 { cap001262 iff cap001262c }
check CapBenchEquivalent_cap001262 for 4
