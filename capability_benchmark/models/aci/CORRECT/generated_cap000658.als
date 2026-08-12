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

pred cap000658 { (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) }
pred cap000658c { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA)) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000658 { cap000658 iff cap000658c }
check CapBenchEquivalent_cap000658 for 4
