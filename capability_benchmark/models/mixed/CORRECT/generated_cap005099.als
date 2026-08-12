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

pred cap005099 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchB or some capBenchR) and some CapBenchB)) and ((some CapBenchA and no CapBenchA) or some capBenchR))) }
pred cap005099c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchA) or some capBenchR)) or (not (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005099 { cap005099 iff cap005099c }
check CapBenchEquivalent_cap005099 for 4
