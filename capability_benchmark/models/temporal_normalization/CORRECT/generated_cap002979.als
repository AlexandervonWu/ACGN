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

pred inv2 {
all x : User | x not in x.follows
}

pred inv2c {
	all p : User | p not in p.follows
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002979 { not (((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) since (((some capBenchR and some CapBenchB) or no CapBenchA))) }
pred cap002979c { ((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) triggered (not ((some capBenchR and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002979 { cap002979 iff cap002979c }
check CapBenchEquivalent_cap002979 for 4
