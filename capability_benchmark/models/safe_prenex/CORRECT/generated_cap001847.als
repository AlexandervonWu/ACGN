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

pred inv1 {
all p:Photo| one u:User| u->p in posts
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001847 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or no CapBenchB) and some capBenchS))) }
pred cap001847c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap001847 { cap001847 iff cap001847c }
check CapBenchEquivalent_cap001847 for 4
