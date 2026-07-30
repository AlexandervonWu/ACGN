var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv17 {
always all t: Trash | after no t
}

pred inv17c {
	always (no Trash&File')
}

check correct { inv17 <=> inv17c}
pred under { inv17 and !inv17c}
pred over { !inv17 and inv17c}
run over 
run under 


