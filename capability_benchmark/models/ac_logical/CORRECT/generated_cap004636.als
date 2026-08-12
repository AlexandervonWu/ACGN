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
all p: Photo - Ad, u1: User | some u2: User | u1->p in sees => u2->p in posts and u1->u2 in follows
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

pred cap004636 { not ((inv3 and ((some CapBenchA and some CapBenchB) or no CapBenchA)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap004636c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (not (inv3 and ((some CapBenchA and some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004636 { cap004636 iff cap004636c }
check CapBenchEquivalent_cap004636 for 4
