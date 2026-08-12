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

pred cap000572 { ((inv5 and ((some CapBenchA and some CapBenchB) or some CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000572c { (((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)) and (inv5 and ((some CapBenchA and some CapBenchB) or some CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
assert CapBenchEquivalent_cap000572 { cap000572 iff cap000572c }
check CapBenchEquivalent_cap000572 for 4
