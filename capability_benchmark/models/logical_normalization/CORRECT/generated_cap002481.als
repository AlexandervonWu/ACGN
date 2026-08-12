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

pred cap002481 { not ((inv1 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA)) }
pred cap002481c { ((not (inv1 and ((some CapBenchB or some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002481 { cap002481 iff cap002481c }
check CapBenchEquivalent_cap002481 for 4
