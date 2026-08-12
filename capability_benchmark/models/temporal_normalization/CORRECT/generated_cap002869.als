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

pred inv1 {
all x : Photo | one posts.x
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002869 { not once ((inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap002869c { historically (not (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap002869 { cap002869 iff cap002869c }
check CapBenchEquivalent_cap002869 for 4
