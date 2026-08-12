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

pred cap004663 { not ((inv3 and ((no CapBenchB or some capBenchR) and no CapBenchA)) and ((some CapBenchA and no CapBenchA) or some capBenchS)) }
pred cap004663c { ((not ((some CapBenchA and no CapBenchA) or some capBenchS)) or (not (inv3 and ((no CapBenchB or some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004663 { cap004663 iff cap004663c }
check CapBenchEquivalent_cap004663 for 4
