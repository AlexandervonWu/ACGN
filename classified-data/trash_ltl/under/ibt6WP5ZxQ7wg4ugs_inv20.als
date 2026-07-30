var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv20 {
always (all f : Trash | f in Protected since f in Trash)
}

pred inv20c {
	always (all f:Trash | not (f not in Trash triggered f in Protected))
}

check correct { inv20 <=> inv20c}
pred under { inv20 and !inv20c}
pred over { !inv20 and inv20c}
run over 
run under 


