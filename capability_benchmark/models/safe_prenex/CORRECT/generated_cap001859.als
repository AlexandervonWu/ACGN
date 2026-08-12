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

pred cap001859 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
pred cap001859c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap001859 { cap001859 iff cap001859c }
check CapBenchEquivalent_cap001859 for 4
