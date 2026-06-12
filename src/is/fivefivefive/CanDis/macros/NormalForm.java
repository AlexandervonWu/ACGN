package edu.uta.cse.scope.macros;

import java.util.List;
import java.util.Map;

/**
 * This class encodes the normal form of a formula or function, which consists of a quantification tree and a matrix e-graph representation of the formula. 
 * The quantification tree captures the structure of the quantifiers in the formula, while the matrix e-graph captures the structure of the formula itself. 
 * The normal form can be used for distance calculation, as well as for other analyses and transformations on the formula.
 * It is the locus of control for the visitor that generates the normal form from the original formula. 
 */
public class NormalForm {
    private QuantificationTreeNode quantificationTreeRoot;
    // matrix e-graph representation of the formula, where each node is a subformula, and edges represent the structure of the formula.
    private EGraphNode matrixEGraphRoot;
    private List<QuantiVar> params; // the parameters of the formula or function, in the order they appear in the original formula or function declaration.
    private List<QuantiVar> matrixQuantiVars; // the quantified variables in the matrix, in the order they appear in the formula.
    private Map<QuantiVar, QuantificationTreeNode> correspondingQuantificationTreeNodes; // a mapping from quantified variables in the matrix to their corresponding quantification tree nodes, for easy access.

    public NormalForm() {
        // initialize the normal form with empty quantification tree and matrix e-graph, and empty parameter list and quantified variable list.
        this.quantificationTreeRoot = null;
        this.matrixEGraphRoot = null;
        this.params = null;
        this.matrixQuantiVars = null;
        this.correspondingQuantificationTreeNodes = null;
    
    }

    public QuantificationTreeNode getQuantificationTree() {
        return this.quantificationTreeRoot;
    }
    public EGraphNode getMatrixEGraph() {
        return this.matrixEGraphRoot;
    }
    public List<QuantiVar> getParams() {
        return this.params;
    }
    public List<QuantiVar> getMatrixQuantiVars() {
        return this.matrixQuantiVars;
    }
    public Map<QuantiVar, QuantificationTreeNode> getCorrespondingQuantificationTreeNodes() {
        return this.correspondingQuantificationTreeNodes;
    }
    public void addNode(QuantificationTreeNode node) {
        if (this.quantificationTreeRoot == null) {
            this.quantificationTreeRoot = node;
        } else {
            // TODO : add the node to the quantification tree, according to the structure of the original formula.
            // this can be done by maintaining a stack of the current path in the quantification tree, and adding the node as a child of the current node on the stack.
            // for simplicity, we assume that the visitor that generates the normal form will handle this part, and we just provide a method to add a node to the quantification tree.
        }
    }
    public void addEClass(EGraphNode node) {
        if (this.matrixEGraphRoot == null) {
            this.matrixEGraphRoot = node;
        } else {
            // TODO : add the node to the matrix e-graph, according to the structure of the original formula.
            // this can be done by maintaining a stack of the current path in the matrix e-graph, and adding the node as a child of the current node on the stack.
            // for simplicity, we assume that the visitor that generates the normal form will handle this part, and we just provide a method to add a node to the matrix e-graph.
        }
    }
    public void addParam(QuantiVar param) {
        this.params.add(param);
    }
    public void addMatrixQuantiVar(QuantificationTreeNode qtNode, QuantiVar quantiVar) {
        this.matrixQuantiVars.add(quantiVar);
        this.correspondingQuantificationTreeNodes.put(quantiVar, qtNode);
        qtNode.addQuantiVar(quantiVar);
    }
}
