sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv8 {
all en, ex : Track | en in Entry and ex in Exit implies ex in en.^succs
}

pred inv8c {
	all e : Entry, x : Exit | x in e.*succs
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 

