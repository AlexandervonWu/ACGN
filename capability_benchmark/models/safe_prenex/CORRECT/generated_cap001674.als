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

pred cap001674 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
pred cap001674c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001674 { cap001674 iff cap001674c }
check CapBenchEquivalent_cap001674 for 4
