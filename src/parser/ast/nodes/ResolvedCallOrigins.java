package parser.ast.nodes;

import edu.mit.csail.sdg.ast.ExprCall;
import java.util.IdentityHashMap;
import java.util.Map;
import parser.etc.NodeMap;

/**
 * Receives the original Alloy ExprCall from the pinned parser adapter's Call
 * constructor. The private origin table is sealed before the parsed ModelUnit
 * is returned. Public adapter maps are editable and do not supply authority.
 */
public final class ResolvedCallOrigins extends NodeMap {
  private final Map<Call, ExprCall> originals = new IdentityHashMap<>();
  private final NodeMap inherited;
  private boolean sealed;

  ResolvedCallOrigins(Node parent) {
    inherited = parent == null ? null : parent.getNodeMap();
  }

  @Override
  public void addToMap(Object source, Node adapter) {
    if (!sealed && source instanceof ExprCall resolved && adapter instanceof Call call) {
      originals.putIfAbsent(call, resolved);
    }
    // Non-root callers with existing maps still receive every original mapping.
    // Ordinary null-parent models previously retained no public adapter map.
    if (inherited != null) inherited.addToMap(source, adapter);
    else if (adapter instanceof Call) super.addToMap(source, adapter);
  }

  @Override public Map<Object, Node> getS2D() {
    return inherited != null ? inherited.getS2D() : super.getS2D();
  }

  @Override public Map<Node, Object> getD2S() {
    return inherited != null ? inherited.getD2S() : super.getD2S();
  }

  @Override public Node findDst(Object source) {
    return inherited != null ? inherited.findDst(source) : super.findDst(source);
  }

  @Override public Object findSrc(Node node) {
    return inherited != null ? inherited.findSrc(node) : super.findSrc(node);
  }

  void seal() { sealed = true; }

  public static ExprCall original(Call call) {
    return call.getNodeMap() instanceof ResolvedCallOrigins origins && origins.sealed
        ? origins.originals.get(call) : null;
  }
}
