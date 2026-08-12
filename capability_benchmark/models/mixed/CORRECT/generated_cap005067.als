sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all e : Track | e in Entry iff (all t : Track | t not in succs.e)
}

pred inv4c {
	all t : Track | t in Entry iff no succs.t
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005067 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap005067c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) or (not (inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005067 { cap005067 iff cap005067c }
check CapBenchEquivalent_cap005067 for 4
