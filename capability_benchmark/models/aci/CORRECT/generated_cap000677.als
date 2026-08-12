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
all u : User | u not in u.follows
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

pred cap000677 { (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap000677c { ((inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) or (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
assert CapBenchEquivalent_cap000677 { cap000677 iff cap000677c }
check CapBenchEquivalent_cap000677 for 4
