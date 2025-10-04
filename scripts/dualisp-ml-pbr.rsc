# 🧩 dualisp-ml-pbr.rsc  
### RouterOS 7.20 - hAP ax²  
### Dual ISP + Policy Based Routing (PBR)  
### Default ISP2 (Fastlink), Mobile Legends via ISP1 (Telkom)  
### Asumsikan DHCP, DNS, NTP, NAT dasar sudah dikonfigurasi (pre-install manual)

```rsc
##########################################
# RouterOS 7.20 - hAP ax²
# Dual ISP + Policy Based Routing (PBR)
# Default ISP2 (Fastlink), ML via ISP1 (Telkom)
# Assumes DHCP, DNS, NTP, NAT basic already configured
##########################################

# === BRIDGE LAN ===
/interface/bridge
:if ([:len [/interface/bridge/find name="bridge-LAN"]] = 0) do={
    /interface/bridge/add name=bridge-LAN
}

/interface/bridge/port
:foreach p in={"ether1";"ether4";"ether5";"wifi1";"wifi2"} do={
    :if ([:len [/interface/bridge/port/find where bridge="bridge-LAN" && interface=$p]] = 0) do={
        /interface/bridge/port/add bridge=bridge-LAN interface=$p
    }
}

# === LAN IP ADDRESS ===
/ip/address
:if ([:len [/ip/address/find where address="10.10.0.1/12"]] = 0) do={
    /ip/address/add address=10.10.0.1/12 interface=bridge-LAN comment="LAN / Hotspot"
}

# === ROUTING TABLES ===
/routing/table
:if ([:len [/routing/table/find name="to-ISP1"]] = 0) do={ /routing/table/add fib name=to-ISP1 }
:if ([:len [/routing/table/find name="to-ISP2"]] = 0) do={ /routing/table/add fib name=to-ISP2 }

# === DEFAULT ROUTES (customize gateway if static IP used) ===
/ip/route
:if ([:len [/ip/route/find where comment="Default via ISP1 Telkom"]] = 0) do={
    /ip/route/add dst-address=0.0.0.0/0 gateway=172.16.0.1 routing-table=to-ISP1 comment="Default via ISP1 Telkom"
}
:if ([:len [/ip/route/find where comment="Default via ISP2 Fastlink"]] = 0) do={
    /ip/route/add dst-address=0.0.0.0/0 gateway=172.8.45.1 routing-table=to-ISP2 comment="Default via ISP2 Fastlink"
}
:if ([:len [/ip/route/find where comment="Main default ISP2"]] = 0) do={
    /ip/route/add dst-address=0.0.0.0/0 gateway=172.8.45.1 comment="Main default ISP2"
}

# === LOCAL ADDRESS-LIST (Bypass local traffic) ===
/ip/firewall/address-list
:if ([:len [/ip/firewall/address-list/find where address="10.10.0.0/12"]] = 0) do={
    /ip/firewall/address-list/add address=10.10.0.0/12 list=LOCAL comment="LAN/Hotspot subnet"
}
:if ([:len [/ip/firewall/address-list/find where address="172.0.0.0/8"]] = 0) do={
    /ip/firewall/address-list/add address=172.0.0.0/8 list=LOCAL comment="Private/Local range"
}

# === FIREWALL MANGLE (Bypass local + ML routing) ===
/ip/firewall/mangle/remove [find]
/ip/firewall/mangle
add chain=prerouting src-address-list=LOCAL dst-address-list=LOCAL action=accept comment="Bypass LOCAL prerouting"
add chain=postrouting src-address-list=LOCAL dst-address-list=LOCAL action=accept comment="Bypass LOCAL postrouting"
add chain=forward src-address-list=LOCAL dst-address-list=LOCAL action=accept comment="Bypass LOCAL forward"
add chain=input src-address-list=LOCAL dst-address-list=LOCAL action=accept comment="Bypass LOCAL input"
add chain=output src-address-list=LOCAL dst-address-list=LOCAL action=accept comment="Bypass LOCAL output"

# === MOBILE LEGENDS TRAFFIC MARK ===
# TCP
add chain=prerouting protocol=tcp dst-port=5000-5221,5224-5227,5229-5241,5243-5287 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="ML TCP 1"
add chain=prerouting protocol=tcp dst-port=5289-5352,5354-5509,5517,5520-5529,5551-5569 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="ML TCP 2"
add chain=prerouting protocol=tcp dst-port=5601-5700,9000-9010,9443,10003,30000-30900 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="ML TCP 3"

# UDP
add chain=prerouting protocol=udp dst-port=2702,3702,4001-4009,5000-5221,5224-5241 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="ML UDP 1"
add chain=prerouting protocol=udp dst-port=5243-5287,5289-5352,5354-5509,5507,5517-5529 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="ML UDP 2"
add chain=prerouting protocol=udp dst-port=5551-5569,5601-5700,8001,8130,9000-9010,9120,9992 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="ML UDP 3"
add chain=prerouting protocol=udp dst-port=10003,30000-30900 action=mark-connection new-connection-mark=ml_conn passthrough=yes comment="ML UDP 4"

# === PBR ROUTING ===
add chain=prerouting connection-mark=ml_conn action=mark-routing new-routing-mark=to-ISP1 passthrough=no comment="Mobile Legends via ISP1"
add chain=prerouting src-address=10.10.0.0/12 connection-mark=!ml_conn action=mark-routing new-routing-mark=to-ISP2 passthrough=no comment="Default via ISP2"

# === FINAL LOG ===
:log info "Dual ISP + PBR applied. Default: ISP2 (Fastlink), ML: ISP1 (Telkom)."
```
