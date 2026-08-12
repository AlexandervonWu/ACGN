sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s : Signal | one signals.s
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

pred cap002390 { not not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002390c { (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002390 { cap002390 iff cap002390c }
check CapBenchEquivalent_cap002390 for 4
