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
all u:User | u not in u.follows
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

pred cap002771 { not eventually ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap002771c { always (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002771 { cap002771 iff cap002771c }
check CapBenchEquivalent_cap002771 for 4
