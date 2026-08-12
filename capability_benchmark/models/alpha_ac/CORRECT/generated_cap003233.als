sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t : Track | t in Junction <=> #(succs.t) > 1
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

pred cap003233 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some CapBenchB or some capBenchS) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003233c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv5 and ((some CapBenchB or some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap003233 { cap003233 iff cap003233c }
check CapBenchEquivalent_cap003233 for 4
