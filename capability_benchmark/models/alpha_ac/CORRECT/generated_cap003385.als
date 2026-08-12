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

pred cap003385 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)) }
pred cap003385c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003385 { cap003385 iff cap003385c }
check CapBenchEquivalent_cap003385 for 4
