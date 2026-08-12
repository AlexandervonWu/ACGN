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

pred cap002850 { not historically ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
pred cap002850c { once (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002850 { cap002850 iff cap002850c }
check CapBenchEquivalent_cap002850 for 4
