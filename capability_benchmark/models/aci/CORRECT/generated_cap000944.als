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

pred cap000944 { ((inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some capBenchS) or some CapBenchB) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)) }
pred cap000944c { (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR) and (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some capBenchS) or some CapBenchB)) }
assert CapBenchEquivalent_cap000944 { cap000944 iff cap000944c }
check CapBenchEquivalent_cap000944 for 4
