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

pred cap002898 { not historically ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002898c { once (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002898 { cap002898 iff cap002898c }
check CapBenchEquivalent_cap002898 for 4
