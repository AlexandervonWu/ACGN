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

pred cap004589 { not ((inv5 and ((some CapBenchB or no CapBenchB) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)) }
pred cap004589c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchR)) or (not (inv5 and ((some CapBenchB or no CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004589 { cap004589 iff cap004589c }
check CapBenchEquivalent_cap004589 for 4
