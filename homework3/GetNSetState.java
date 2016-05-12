import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private AtomicIntegerArray value;
    private byte maxval;
    // each constructor has to convert byte array into AtomicIntegerArray
    GetNSetState(byte[] v) { value = new AtomicIntegerArray(v.length); 
    						for (int i=0;i<v.length;i++){
    							value.set(i, v[i]&0xff);
    						}
    						maxval = 127; }

    GetNSetState(byte[] v, byte m) { value = new AtomicIntegerArray(v.length); 
									for (int i=0;i<v.length;i++){
											value.set(i, v[i]&0xff);
									}							
									maxval = m; }

    public int size() { return value.length(); }

    // current method has to convert an AtomicIntegerArray to a byte array
    public byte[] current() { byte[] v= new byte[value.length()];
    						for(int k=0;k<value.length();k++){
    							v[k]=(byte) value.get(k);
    						}
    						return v;
    						}
    // using the increment/decrement and get methods to update the array
    public boolean swap(int i, int j) {
	if (value.get(i) <= 0 || value.get(j) >= maxval) {
	    return false;
	}
	value.decrementAndGet(i);;
	value.incrementAndGet(j);
	return true;
    }
}
