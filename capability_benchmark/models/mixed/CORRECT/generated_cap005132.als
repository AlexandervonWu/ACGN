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

pred cap005132 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and some CapBenchA) or no CapBenchA)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap005132c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (not (inv2 and ((some capBenchR and some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005132 { cap005132 iff cap005132c }
check CapBenchEquivalent_cap005132 for 4
