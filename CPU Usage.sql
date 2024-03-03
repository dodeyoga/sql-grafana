WITH grup (groupid) AS ( SELECT groupid FROM hstgrp WHERE name LIKE CONCAT ("%","$APP","%") ),
	
ListServer (hostid,name) AS (
		SELECT hosts.hostid, hosts.name
		FROM hosts
		JOIN  hosts_groups ON hosts.hostid = hosts_groups.hostid
		JOIN grup ON hosts_groups.groupid = grup.groupid
),

histupd (itemid,clock,value,ns) AS (
  SELECT * FROM history_uint WHERE clock > UNIX_TIMESTAMP(NOW()) - 60
),

hist_cpuutil (vm,cpu) as (
  SELECT DISTINCT ListServer.name AS vm, histupd.value AS cpu
  FROM ListServer
  JOIN (SELECT * FROM items WHERE key_ = "vmware.vm.cpu.usage.perf[{$VMWARE.URL},{$VMWARE.VM.UUID}]") AS items ON ListServer.hostid = items.hostid
  JOIN histupd ON histupd.itemid = items.itemid WHERE (histupd.value IS NOT NULL)
  LIMIT 10000
)

SELECT DISTINCT vm, cpu FROM hist_cpuutil
