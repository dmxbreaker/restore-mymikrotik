/interface bridge
add name=bridge-LAN

/ip address
add address=10.10.0.1/12 interface=bridge-LAN comment="LAN/Hotspot"

/routing/table
add fib name=to-ISP1
add fib name=to-ISP2

/ip firewall address-list
add address=10.10.0.0/12 list=LOCAL
