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

pred cap002963 { not eventually ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002963c { always (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002963 { cap002963 iff cap002963c }
check CapBenchEquivalent_cap002963 for 4
