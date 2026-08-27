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

pred cap000996 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000996c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000996 { cap000996 iff cap000996c }
check CapBenchEquivalent_cap000996 for 4
