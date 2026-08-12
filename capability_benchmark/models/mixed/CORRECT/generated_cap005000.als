sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t:Track | t in Entry <=> t not in Track.^succs
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

pred cap005000 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchA)) and ((some capBenchS or some capBenchS) or no CapBenchA))) }
pred cap005000c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchS) or no CapBenchA)) or (not (inv4 and ((some CapBenchA and some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005000 { cap005000 iff cap005000c }
check CapBenchEquivalent_cap005000 for 4
