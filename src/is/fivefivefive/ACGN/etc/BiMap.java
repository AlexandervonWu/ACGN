package is.fivefivefive.ACGN.etc;

import java.io.Serializable;
import java.util.Map;

import is.fivefivefive.alloyasg.etc.DoubleMap;

// Serializable extension of AlloyASG.DoubleMap
public class BiMap<K, V> extends DoubleMap<K, V> implements Serializable {
    public BiMap() {
        super();
    }
    public BiMap(Map<K, V> lmap) {
        super(lmap);
    }
}