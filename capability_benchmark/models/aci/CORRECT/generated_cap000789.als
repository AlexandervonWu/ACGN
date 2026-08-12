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
all p: Photo | one u: User| p in u.posts
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

pred cap000789 { ((inv1 and ((some CapBenchB or some capBenchR) or some capBenchR)) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
pred cap000789c { (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB) or (inv1 and ((some CapBenchB or some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap000789 { cap000789 iff cap000789c }
check CapBenchEquivalent_cap000789 for 4
