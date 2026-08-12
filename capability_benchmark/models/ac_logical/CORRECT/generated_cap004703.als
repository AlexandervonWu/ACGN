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

pred inv3 {
all x : User| x.sees- Ad in x.follows.posts
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004703 { not ((inv3 and ((no CapBenchB or some CapBenchB) and no CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap004703c { ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) or (not (inv3 and ((no CapBenchB or some CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004703 { cap004703 iff cap004703c }
check CapBenchEquivalent_cap004703 for 4
