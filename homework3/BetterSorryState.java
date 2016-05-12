import java.util.concurrent.atomic.AtomicInteger;

class BetterSorryState implements State {
    private byte[] value;
    private byte maxval;

    BetterSorryState(byte[] v) { value = v; maxval = 127; }

    BetterSorryState(byte[] v, byte m) { value = v; maxval = m;}

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
	 byte vi=value[i];
	 byte vj=value[j];
    	if (vi <= 0 || vj >= maxval) {
    		return false;
    		}
    	 value[i]--;
    	 value[j]++;
    	return true;
 } 
}
