import java.util.concurrent.atomic.AtomicBoolean;

class BetterSafeState implements State {
    private byte[] value;
    private byte maxval;
    private AtomicBoolean locked = new AtomicBoolean(false);

    BetterSafeState(byte[] v) { value = v; maxval = 127; }

    BetterSafeState(byte[] v, byte m) { value = v; maxval = m;}

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {

    if (locked.equals(false)){//check the flag to see if the volatile resource is locked or not

    	locked.compareAndSet(false, true); //LOCK this part of the code for a thread to perform read/write operation

    	if (value[i] <= 0 || value[j] >= maxval) {
    		locked.compareAndSet(true, false); //UNLOCK after READ
    		return false;
    		}
    	value[i]--;
    	value[j]++;
    	locked.compareAndSet(true, false);// or UNLOCK after WRITE
    }
    	return true;
  
}
}
