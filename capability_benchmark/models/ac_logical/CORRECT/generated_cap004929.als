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

pred cap004929 { not ((inv1 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and no CapBenchB) and some CapBenchB)) }
pred cap004929c { ((not ((no CapBenchA and no CapBenchB) and some CapBenchB)) or (not (inv1 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004929 { cap004929 iff cap004929c }
check CapBenchEquivalent_cap004929 for 4
