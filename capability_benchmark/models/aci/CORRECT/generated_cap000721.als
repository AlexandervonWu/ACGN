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

pred cap000721 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
pred cap000721c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((some capBenchS or no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000721 { cap000721 iff cap000721c }
check CapBenchEquivalent_cap000721 for 4
