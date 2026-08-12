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

pred cap000555 { ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) or ((some capBenchR and some capBenchR) or no CapBenchB) or ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000555c { (((some capBenchR and some capBenchR) or no CapBenchB) or ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap000555 { cap000555 iff cap000555c }
check CapBenchEquivalent_cap000555 for 4
