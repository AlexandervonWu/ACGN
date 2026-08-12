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

pred cap000850 { (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) }
pred cap000850c { ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000850 { cap000850 iff cap000850c }
check CapBenchEquivalent_cap000850 for 4
