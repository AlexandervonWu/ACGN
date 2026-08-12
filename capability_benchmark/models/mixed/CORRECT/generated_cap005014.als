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

pred cap005014 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap005014c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005014 { cap005014 iff cap005014c }
check CapBenchEquivalent_cap005014 for 4
