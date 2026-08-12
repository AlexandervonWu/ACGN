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

pred inv5 {
all i:Influencer | follows.i = (User-i)
}

pred inv5c {
	all i : Influencer | follows.i = User - i
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002002 { ((inv5 and ((no CapBenchA and some CapBenchA) and some CapBenchA)) implies ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) }
pred cap002002c { ((not (inv5 and ((no CapBenchA and some CapBenchA) and some CapBenchA))) or ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) }
assert CapBenchEquivalent_cap002002 { cap002002 iff cap002002c }
check CapBenchEquivalent_cap002002 for 4
