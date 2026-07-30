var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv16 {
always(all f:Protected | historically f in Protected)
}

pred inv16c {
	always (all f:Protected | historically f in Protected)
}

check correct { inv16 <=> inv16c}
pred under { inv16 and !inv16c}
pred over { !inv16 and inv16c}
run over 
run under 


