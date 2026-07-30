var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv20 {
always all f : File | always f in Trash since f not in Protected
}

pred inv20c {
	always (all f:Trash | not (f not in Trash triggered f in Protected))
}

check correct { inv20 <=> inv20c}
pred under { inv20 and !inv20c}
pred over { !inv20 and inv20c}
run over 
run under 


