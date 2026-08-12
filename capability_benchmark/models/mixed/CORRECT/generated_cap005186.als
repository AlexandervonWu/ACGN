sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t:Track | t in Junction iff #(succs.t) > 1
}

pred inv5c {
	all t : Track | t not in Junction iff lone succs.t
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005186 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
pred cap005186c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) or (not (inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005186 { cap005186 iff cap005186c }
check CapBenchEquivalent_cap005186 for 4
