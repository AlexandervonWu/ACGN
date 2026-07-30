sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv8 {
all x : Track | x in Entry-Exit => x.^(succs) in Exit && x in Exit-Entry => x.^(succs) in Entry
}

pred inv8c {
	all e : Entry, x : Exit | x in e.*succs
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 

