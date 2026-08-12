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

pred cap002612 { not (((inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) until (((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap002612c { ((not (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) releases (not ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002612 { cap002612 iff cap002612c }
check CapBenchEquivalent_cap002612 for 4
