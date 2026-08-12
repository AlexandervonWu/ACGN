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

pred cap000560 { ((inv5 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((some CapBenchB or some capBenchS) or no CapBenchB) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000560c { (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and (inv5 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((some CapBenchB or some capBenchS) or no CapBenchB)) }
assert CapBenchEquivalent_cap000560 { cap000560 iff cap000560c }
check CapBenchEquivalent_cap000560 for 4
