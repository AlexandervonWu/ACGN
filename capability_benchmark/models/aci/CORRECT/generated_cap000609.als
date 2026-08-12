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

pred cap000609 { ((inv5 and ((some capBenchS or some capBenchS) or some CapBenchB)) or ((no CapBenchA and no CapBenchB) and some capBenchR) or ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000609c { (((no CapBenchA and no CapBenchB) and some capBenchR) or ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB) or (inv5 and ((some capBenchS or some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap000609 { cap000609 iff cap000609c }
check CapBenchEquivalent_cap000609 for 4
