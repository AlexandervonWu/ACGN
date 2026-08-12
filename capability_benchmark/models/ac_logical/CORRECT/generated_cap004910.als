sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all e : Entry | some e.signals & Speed
}

pred inv6c {
	all t : Entry | some t.signals & Speed
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004910 { not ((inv6 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) }
pred cap004910c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) or (not (inv6 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004910 { cap004910 iff cap004910c }
check CapBenchEquivalent_cap004910 for 4
