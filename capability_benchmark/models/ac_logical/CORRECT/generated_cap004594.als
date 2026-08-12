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

pred cap004594 { not ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)) and ((no CapBenchB or some CapBenchB) and some capBenchR)) }
pred cap004594c { ((not ((no CapBenchB or some CapBenchB) and some capBenchR)) or (not (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004594 { cap004594 iff cap004594c }
check CapBenchEquivalent_cap004594 for 4
