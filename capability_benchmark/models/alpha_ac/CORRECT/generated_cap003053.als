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

pred cap003053 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((no CapBenchA and some capBenchR) and no CapBenchB)) }
pred cap003053c { all renamed: CapBenchA | (((no CapBenchA and some capBenchR) and no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap003053 { cap003053 iff cap003053c }
check CapBenchEquivalent_cap003053 for 4
