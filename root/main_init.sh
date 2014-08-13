
echo -e "I'm script \"$0\". I'm started as: "$(id)
while [ 1 ]
do
  /root/s2i.bin < /dev/console > /dev/console
  echo "LOCK_LED 0" > /dev/axe/fp-0
done

