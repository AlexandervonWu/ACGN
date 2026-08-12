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

pred cap001164 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
pred cap001164c { all a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap001164 { cap001164 iff cap001164c }
check CapBenchEquivalent_cap001164 for 4
