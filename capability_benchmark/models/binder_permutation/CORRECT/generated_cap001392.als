sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t: Track | no Junction & t.succs => no Semaphore & t.signals
}

pred inv9c {
	all t : Track | no t.succs & Junction implies no t.signals & Semaphore
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001392 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001392c { all a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001392 { cap001392 iff cap001392c }
check CapBenchEquivalent_cap001392 for 4
