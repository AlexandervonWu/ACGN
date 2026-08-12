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

pred inv7 {
all u, s: User | s in u.suggested iff s not in u.follows and s in u.follows.follows and s != u
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002797 { not once ((inv7 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
pred cap002797c { historically (not (inv7 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap002797 { cap002797 iff cap002797c }
check CapBenchEquivalent_cap002797 for 4
