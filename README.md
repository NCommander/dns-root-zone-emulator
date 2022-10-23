# Root Zone Emulator Useful Commands
This is a working simulation of the Internet root zone with DNSSEC, and recursive resolution. All commands are assumed to be run from recursive resolver container

## Show glue records
DNS delegation takes the form of NS records, which point to the next server in the chain (i.e., nynex.internic). For example:

```
root@hermes:/etc/bind# dig @172.16.0.103 internic NS +short
ns1.internic.
```

This provides a bootstrapping problem, which is solved with glue records as an additional section:

```
root@hermes:/etc/bind# dig @172.16.0.103 internic NS
;; ANSWER SECTION:
internic.               3598    IN      NS      ns1.internic.

;; ADDITIONAL SECTION:
ns1.internic.           3600    IN      A       172.16.0.101
ns1.internic.           3600    IN      AAAA    fd36:7b4:c298:bce5::1001
```

Root zone glue record from the hints file: 

`dig @172.16.0.103 root-zone.internic AAAA`

## Root Zone KSK
Trust in DNSSEC is handled through the root KSK, which anchors each TLD signing key. In TLS terms, it's a self-signed certificate, stored in the DNSKEY location

`dig @172.16.0.103 . DNSKEY`

Records from the root can be validated with delv

`delv -a ./emulator.key @172.16.0.103 internic NS`

```
mcasadevall@beacon:~$ delv -a ./emulator_key @172.16.0.103 internic NS
;; ./emulator_key:23: option 'managed-keys' is deprecated
; fully validated
internic.               1884    IN      NS      ns1.internic.
internic.               1884    IN      RRSIG   [...]
```

## NSEC
DNSSEC has the concept of secure negation, which prevents lies by omission. These can be handled through NSEC, or NSEC3. NSEC is simpler, but allows for zone enumeration; while NSEC3 uses hashing and ranges to declare what parts of the zone are covered.

`dig @172.16.0.103 pi +dnssec`

The response will have a NSEC record showing that pi doesn't exist:

```
.                       3600    IN      NSEC    internic. NS SOA RRSIG NSEC DNSKEY TYPE65534
internic.               3600    IN      NSEC    . NS DS RRSIG NSEC
```

NSEC records must be validated with the RRSIG set

```
mcasadevall@beacon:~$ delv -a ./emulator.key @172.16.0.103 doesntexist NS
;; ./emulator.key:23: option 'managed-keys' is deprecated
;; resolution failed: ncache nxdomain
; negative response, fully validated
; doesntexist.          3600    IN      \-ANY   ;-$NXDOMAIN
; . SOA root-zone.internic. hostmaster.root-zone.internic. 2018102806 14400 900 86400 3600
; . RRSIG SOA ...
; . RRSIG NSEC ...
; . NSEC internic. NS SOA RRSIG NSEC DNSKEY TYPE65534
```

## .internic TLD
The root server emulator defines one TLD, .internic. It's defined in the root zone as follows:

```
internic.       IN NS nynex.internic.
internic.		IN DS 52615 8 2 B2EE5E977B544C70FE3610FBB3BD2D2B36CE2D68F5E63F8310DA85C3BB5D611A
```

.internic is signed with its own KSK, which is designated from the root via the DS record in the root. A glue record is provided to help with lookup

```
nynex.internic.	IN	A	172.16.0.101
nynex.internic.	IN	AAAA	fd36:7b4:c298:bce5::1001
```

## .internic DS validation

Validating internic requires getting a chain of trust from the root zone downward, as seen with delv.

`delv -a ./emulator.key @172.16.0.103 internic DNSKEY +vtrace`

The DNSKEY record exists in the TLD which is its own signing key. This can be validated from the root trust anchor, and the DS record in the root.

## Reverse record lookup

The emulator provides a full reverse zone, including signatures, in both IPv4 and IPv6

ARPA zone test record:
`delv -a ./emulator.key @172.16.0.103 test.arpa TXT`

Reverse lookup: Olypmus
`host fd36:7b4:c298:bce5::1002 fd36:7b4:c298:bce5::1003`
`delv -a ./emulator.key @fd36:7b4:c298:bce5::1003 2.0.0.1.0.0.0.0.0.0.0.0.0.0.0.0.5.e.c.b.8.9.2.c.4.b.7.0.6.3.d.f.ip6.arpa PTR`


```
mcasadevall@beacon:~$ host fd36:7b4:c298:bce5::1002 fd36:7b4:c298:bce5::1003
Using domain server:
Name: fd36:7b4:c298:bce5::1003
Address: fd36:7b4:c298:bce5::1003#53
Aliases: 

2.0.0.1.0.0.0.0.0.0.0.0.0.0.0.0.5.e.c.b.8.9.2.c.4.b.7.0.6.3.d.f.ip6.arpa domain name pointer olypmus.nynex.internic.
mcasadevall@beacon:~$ delv -a ./emulator.key @fd36:7b4:c298:bce5::1003 2.0.0.1.0.0.0.0.0.0.0.0.0.0.0.0.5.e.c.b.8.9.2.c.4.b.7.0.6.3.d.f.ip6.arpa PTR
;; ./emulator.key:23: option 'managed-keys' is deprecated
; fully validated
2.0.0.1.0.0.0.0.0.0.0.0.0.0.0.0.5.e.c.b.8.9.2.c.4.b.7.0.6.3.d.f.ip6.arpa. 3566 IN PTR olypmus.nynex.internic.
2.0.0.1.0.0.0.0.0.0.0.0.0.0.0.0.5.e.c.b.8.9.2.c.4.b.7.0.6.3.d.f.ip6.arpa. 3566 IN RRSIG	PTR 8 34 3600 20221121083254 20221023193407 4308 arpa. ZSwxnXKr2/SO6v9w4YSFIkDFsSzSi4VkiLssYqaimixsF7At49z6D9XS ZJeM2xiCK41MFww7VvQYuOuVpYiYbR84Vn2jQmJrd02iMSekz6MLMj1j 7gpWYk+8cEE/eUKLatXLlPRjd7G4Ns71Ezoz1FiBWEJZXF23OaDB/j/+ kKXt7Yp9J0aATTMBWU/F6RTJOXerPTpmu5G9+TdmySJ2+v1Bu0Uz7b0h VoLM/PcjaATf0J5dtNKhscHhX7MCRcGgZ/IHetbcSdJ0SiSgNo8A/WYF e1fRyDdao68RjThDNHA+NfavdMiPRXwoLrbQMozQShQATbxg74br+nBd Wl2uNw==
```

## Endpoint signed records
All machines have host records under *.nynex.internic

`delv -a ./emulator.key @fd36:7b4:c298:bce5::1003 cadimus.nynex.internic`

```
; fully validated
cadimus.nynex.internic.	3600	IN	A	172.16.0.100
cadimus.nynex.internic.	3600	IN	RRSIG	A 8 3 3600 20221110225050 20221023193405 13854 nynex.internic. Kqess+6eTx2+DMSypsyinIasovxd5cTMFmfmvThjJNzWdoi1sfjAftV6 C8R5/YySmP8NDo7zH6UO2MUThs4WEWzqTVER8RM1MvVldcU5RqnSbd9M xMeUqsNbZhsQrQsRaRDwssESbB81abtINF6k6WiKBscC454xZsC0PiMp yXtMbsqaY7aqzlu3JAhERsz7xyhjR7wZtJKB7JHUSlSn3mShWiMSBy5i DWWviTIVQCOva1HazujW1QM0wJi5Umgl2BXUHJDuu3N6A8GN8HNuPtRX UTyhyJCQPf8lRebVAF0enR9tZnvSswagmXJnZ/j+xFbqwJlQ275JUZ0n YAapLQ==
```