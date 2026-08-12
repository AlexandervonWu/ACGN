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

pred cap001238 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
pred cap001238c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap001238 { cap001238 iff cap001238c }
check CapBenchEquivalent_cap001238 for 4
