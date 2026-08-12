sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t : Track | t in Junction <=> #(succs.t) > 1
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

pred cap005156 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchR and no CapBenchB) or no CapBenchA)) and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
pred cap005156c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchB) or some capBenchS)) or (not (inv5 and ((some capBenchR and no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005156 { cap005156 iff cap005156c }
check CapBenchEquivalent_cap005156 for 4
