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

pred cap000937 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000937c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000937 { cap000937 iff cap000937c }
check CapBenchEquivalent_cap000937 for 4
