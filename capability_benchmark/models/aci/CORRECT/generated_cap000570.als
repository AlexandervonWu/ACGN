sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
trans in State -> some Event -> State
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000570 { (some ((CapBenchA.capBenchR).capBenchR) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB))) }
pred cap000570c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000570 { cap000570 iff cap000570c }
check CapBenchEquivalent_cap000570 for 4
