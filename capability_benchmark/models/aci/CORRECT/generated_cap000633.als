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

pred cap000633 { ((inv2 and ((some capBenchS or some CapBenchA) or no CapBenchA)) or ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR) or ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000633c { (((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR) or ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB) or (inv2 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000633 { cap000633 iff cap000633c }
check CapBenchEquivalent_cap000633 for 4
