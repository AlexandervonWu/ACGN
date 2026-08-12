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

pred cap001914 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001914c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001914 { cap001914 iff cap001914c }
check CapBenchEquivalent_cap001914 for 4
