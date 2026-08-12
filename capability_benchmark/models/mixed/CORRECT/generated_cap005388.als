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
all u: User, a: Ad | a in u.posts => u.posts in Ad
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

pred cap005388 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap005388c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) or (not (inv4 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005388 { cap005388 iff cap005388c }
check CapBenchEquivalent_cap005388 for 4
