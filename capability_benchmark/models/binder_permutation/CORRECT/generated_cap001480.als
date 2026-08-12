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

pred cap001480 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001480c { all a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001480 { cap001480 iff cap001480c }
check CapBenchEquivalent_cap001480 for 4
