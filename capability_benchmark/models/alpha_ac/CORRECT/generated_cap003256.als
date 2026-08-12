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

pred cap003256 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some CapBenchA and some CapBenchA) or some capBenchR)) and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003256c { all renamed: CapBenchA | (((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv5 and ((some CapBenchA and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003256 { cap003256 iff cap003256c }
check CapBenchEquivalent_cap003256 for 4
