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
all p:Photo|one u: User| p in u.posts
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

pred cap000808 { (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap000808c { ((inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap000808 { cap000808 iff cap000808c }
check CapBenchEquivalent_cap000808 for 4
