/interface bridge
add name=bridge-LAN

/interface bridge port
add bridge=bridge-LAN interface=ether1
add bridge=bridge-LAN interface=ether4
add bridge=bridge-LAN interface=ether5
add bridge=bridge-LAN interface=wifi1
add bridge=bridge-LAN interface=wifi2

/ip address
add address=10.10.0.1/12 interface=bridge-LAN comment="LAN/Hotspot"
add address=172.16.0.2/24 interface=ether2 comment="ISP1 Telkom"
add address=172.8.45.2/24 interface=ether3 comment="ISP2 Fastlink"

/routing/table
add fib name=to-ISP1
add fib name=to-ISP2

/ip route
add dst-address=0.0.0.0/0 gateway=172.16.0.1 routing-table=to-ISP1 comment="ISP1"
add dst-address=0.0.0.0/0 gateway=172.8.45.1 routing-table=to-ISP2 comment="ISP2"
add dst-address=0.0.0.0/0 gateway=172.8.45.1 comment="Main Default ISP2"

/ip firewall nat
add chain=srcnat out-interface=ether2 action=masquerade comment="NAT ISP1"
add chain=srcnat out-interface=ether3 action=masquerade comment="NAT ISP2"

/ip firewall address-list
add address=10.10.0.0/12 list=LOCAL
add address=172.0.0.0/8 list=LOCAL

/ip firewall mangle
add chain=prerouting src-address-list=LOCAL dst-address-list=LOCAL action=accept
add chain=postrouting src-address-list=LOCAL dst-address-list=LOCAL action=accept
add chain=forward src-address-list=LOCAL dst-address-list=LOCAL action=accept
add chain=input src-address-list=LOCAL dst-address-list=LOCAL action=accept
add chain=output src-address-list=LOCAL dst-address-list=LOCAL action=accept

add chain=prerouting protocol=tcp dst-port=5000-5221,5224-5227,5229-5241,5243-5287 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="Mobile Legends TCP"
add chain=prerouting protocol=tcp dst-port=5289-5352,5354-5509,5517,5520-5529,5551-5569 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="Mobile Legends TCP"
add chain=prerouting protocol=tcp dst-port=5601-5700,9000-9010,9443,10003,30000-30900 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="Mobile Legends TCP"

add chain=prerouting protocol=udp dst-port=2702,3702,4001-4009,5000-5221,5224-5241 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="Mobile Legends UDP"
add chain=prerouting protocol=udp dst-port=5243-5287,5289-5352,5354-5509,5507,5517-5529 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="Mobile Legends UDP"
add chain=prerouting protocol=udp dst-port=5551-5569,5601-5700,8001,8130,9000-9010,9120,9992 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="Mobile Legends UDP"
add chain=prerouting protocol=udp dst-port=10003,30000-30900 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="Mobile Legends UDP"

add chain=prerouting connection-mark=ml_conn action=mark-routing new-routing-mark=to-ISP1 passthrough=no comment="Mobile Legends via ISP1"
add chain=prerouting src-address=10.10.0.0/12 connection-mark=!ml_conn action=mark-routing new-routing-mark=to-ISP2 passthrough=no comment="Default via ISP2"
