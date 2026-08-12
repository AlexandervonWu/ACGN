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
all x : User | x -> x not in follows
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

pred cap002055 { not ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((some capBenchR and some capBenchR) or no CapBenchB)) }
pred cap002055c { ((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) or (not ((some capBenchR and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap002055 { cap002055 iff cap002055c }
check CapBenchEquivalent_cap002055 for 4
