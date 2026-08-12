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

pred cap002368 { ((inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) implies ((some capBenchS or no CapBenchB) or some CapBenchA)) }
pred cap002368c { ((not (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) or ((some capBenchS or no CapBenchB) or some CapBenchA)) }
assert CapBenchEquivalent_cap002368 { cap002368 iff cap002368c }
check CapBenchEquivalent_cap002368 for 4
