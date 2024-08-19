# Community Sessions
This repository is for sessions and presentations given to the broader professional community. 


# List of current sessions: 

## Azure Monitor for SQL PaaS

DBAs need to monitor their systems so they can Alert when something goes wrong, investigate health trends or plan for capacity. In an on-premises or virtual environment you can simply install a monitoring agent on your servers, but what about in a Platform as a Service environment like Azure, where you don’t have access to performance counters or on-disk logs?

This session will cover Azure Monitor, the native monitoring platform for Azure, and how to use it to monitor SQL in a Platform as a Service environment. We’ll review the Metrics and Logs available, how to use solutions like Query Performance Insights, and create custom dashboards to monitor your SQL environment’s vital statistics. Finally, we'll cover how to set up alerts in Azure to keep your team informed.

## HADR Best Practices for Azure SQL

Resiliency of the database platform on Azure is a shared responsibility. While the Azure platform does provide availability SLAs for individual components like Virtual Machines, Managed Instances or SQL Databases, it is still the customer's responsibility to ensure that their configuration of those solutions is built for maximizing uptime.

This session will review the Microsoft-documented best practices for configuring high-availability SQL solutions in Azure. We will walk through how composite SLAs are calculated, zonal vs. regional protection, and how to manage failovers in both proactive and reactive situations. This session will prepare you to implement proper HADR solutions whether you are using SQL Databases, Elastic Pools, Managed Instances, or SQL IaaS Virtual Machines. 

## Online Migration to Azure SQL Database with Transactional Replication

Recently I've worked with many customers who are migrating on-premises databases to Azure SQL. SQL Database offers several offline migration methods, but those methods often require lengthy downtime of the source database and may not be suitable for production workloads. Customers want to minimize downtime during cutover, and test the database before making the switch. While not traditionally considered a cloud migration method, Transactional Replication is often used to fulfill this purpose.

This session will quickly review the basics of Transactional Replication, and then discuss how these can be applied to a PaaS database migration scenario. A full walkthrough of the solution will be provided including setup, validation, and cutover. Some of the common issues with replication setup and troubleshooting will be covered. Finally, there will be a discussion of how to measure performance, and potential impact to the source system.

