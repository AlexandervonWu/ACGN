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

pred cap001526 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((no CapBenchA and no CapBenchB) and some CapBenchA))) }
pred cap001526c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001526 { cap001526 iff cap001526c }
check CapBenchEquivalent_cap001526 for 4
