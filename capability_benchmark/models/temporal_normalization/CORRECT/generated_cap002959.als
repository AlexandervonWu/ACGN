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

pred cap002959 { not once ((inv6 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002959c { historically (not (inv6 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002959 { cap002959 iff cap002959c }
check CapBenchEquivalent_cap002959 for 4
