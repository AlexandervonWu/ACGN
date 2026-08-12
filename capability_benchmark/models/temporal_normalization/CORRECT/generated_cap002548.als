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

pred cap002548 { not always ((inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap002548c { eventually (not (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap002548 { cap002548 iff cap002548c }
check CapBenchEquivalent_cap002548 for 4
