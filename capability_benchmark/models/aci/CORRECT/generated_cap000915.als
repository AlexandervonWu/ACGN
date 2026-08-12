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
all u : User | u.posts in Ad or no u.posts & Ad
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

pred cap000915 { ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or ((some capBenchR and some CapBenchB) or some CapBenchB) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
pred cap000915c { (((some capBenchR and some CapBenchB) or some CapBenchB) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB) or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000915 { cap000915 iff cap000915c }
check CapBenchEquivalent_cap000915 for 4
