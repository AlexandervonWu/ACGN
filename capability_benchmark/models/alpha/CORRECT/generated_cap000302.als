sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s : State | some s.trans
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

pred cap000302 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR))) }
pred cap000302c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap000302 { cap000302 iff cap000302c }
check CapBenchEquivalent_cap000302 for 4
