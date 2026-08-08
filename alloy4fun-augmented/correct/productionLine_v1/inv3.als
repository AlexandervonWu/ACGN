module alloy4fun_augmented_productionLine_v1_inv3
sig Position {}

sig Product {}

sig Component extends Product {
    parts : set Product,
    position : one Position
}
sig Resource extends Product {}

sig Robot {
        position : one Position
}

pred inv3_oracle[] {
all c : Component | some position.(c.position) & Robot
}

pred inv3_correct_0[] {
all c:Component | some r:Robot | c.position in r.position
}

pred inv3_correct_1[] {
all p : Component.position | some r : Robot | r->p in position
}

pred inv3_correct_2[] {
all c : Component | some r : Robot | r.position in c.position
}

pred inv3_correct_3[] {
Component.position in Robot.position
}

pred inv3_correct_4[] {
all c:Component | some(c.position & Robot.position)
}

pred inv3_correct_5[] {
all c : Component, p : c.position | some (Robot <: position).p
}

pred inv3_correct_6[] {
all c:Component, p:c.position | (some r:Robot | r.position = p)
}

pred inv3_correct_7[] {
all c: Component | (c.position) in Robot.position
}

pred inv3_correct_8[] {
all c: Component | some Robot.position & c.position
}

pred inv3_correct_9[] {
all p : Position | some position.p & Component implies some position.p & Robot
}

pred inv3_correct_10[] {
all c:Component, p:Position | some(c.position & Robot.position)
}

pred inv3_correct_11[] {
all c : Component | some r: Robot | c.position = r.position
}

pred inv3_correct_12[] {
all c: Component, p: c.position | some r: Robot | p in r.position
}

pred inv3_correct_13[] {
all c:Component | all p:(c.position) | some r:Robot | r.position in p
}

pred inv3_correct_14[] {
all c : Component | some r:Robot | r.position = c.position
}

pred inv3_correct_15[] {
all c: Component | let p = c.position | some Robot <: position.p
}

pred inv3_correct_16[] {
all c: Component | some Robot<:position.(c.position)
}

