sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all x: Signal | one y : Track | x in y.signals
}

pred inv2c {
	all s : Signal | one signals.s
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000538 { (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) }
pred cap000538c { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap000538 { cap000538 iff cap000538c }
check CapBenchEquivalent_cap000538 for 4
