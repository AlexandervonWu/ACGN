sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e : Event | some (trans.State).e
}

pred inv6c {
	State.trans.State = Event
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002674 { not always ((inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
pred cap002674c { eventually (not (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap002674 { cap002674 iff cap002674c }
check CapBenchEquivalent_cap002674 for 4
