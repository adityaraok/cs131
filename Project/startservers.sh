pkill -f "python serverfinal.py"
fuser -k 5090/tcp
fuser -k 5091/tcp
fuser -k 5092/tcp
fuser -k 5093/tcp
fuser -k 5094/tcp
for i in "Alford" "Bolden" "Parker" "Welsh" "Hamilton"
do
  echo Starting $i
  python serverfinal.py $i &
done
