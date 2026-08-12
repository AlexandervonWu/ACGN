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

pred cap004466 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004466c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004466 { cap004466 iff cap004466c }
check CapBenchEquivalent_cap004466 for 4
