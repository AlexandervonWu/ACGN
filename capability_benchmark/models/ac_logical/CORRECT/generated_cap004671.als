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

pred cap004671 { not ((inv5 and ((no CapBenchB or some capBenchS) and no CapBenchA)) and ((some CapBenchA and no CapBenchB) or some capBenchS)) }
pred cap004671c { ((not ((some CapBenchA and no CapBenchB) or some capBenchS)) or (not (inv5 and ((no CapBenchB or some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004671 { cap004671 iff cap004671c }
check CapBenchEquivalent_cap004671 for 4
