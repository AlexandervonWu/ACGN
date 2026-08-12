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

pred cap000739 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap000739c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap000739 { cap000739 iff cap000739c }
check CapBenchEquivalent_cap000739 for 4
