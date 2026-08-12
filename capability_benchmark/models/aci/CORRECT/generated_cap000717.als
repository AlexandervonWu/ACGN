sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all t:Entry|some s:Speed| t->s in signals
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

pred cap000717 { ((inv6 and ((some CapBenchB or no CapBenchB) or no CapBenchB)) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap000717c { (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA) or (inv6 and ((some CapBenchB or no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000717 { cap000717 iff cap000717c }
check CapBenchEquivalent_cap000717 for 4
