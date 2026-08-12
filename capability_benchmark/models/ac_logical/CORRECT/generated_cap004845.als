sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004845 { not ((inv3 and ((some CapBenchB or no CapBenchB) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) }
pred cap004845c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) or (not (inv3 and ((some CapBenchB or no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap004845 { cap004845 iff cap004845c }
check CapBenchEquivalent_cap004845 for 4
