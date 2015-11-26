#!/bin/bash
## Enroll Sentinel Suite
## Written by Mike Muir for CRTG
## 11/25/15

## This script will download and install the various clients for Sentinel Monitoring (Watchman Monitoring),
## Sentinel Maintenance (Gruntwork) and Bomgar.

# Part 1: Download cradmin installer from AWS instance to /tmp.
curl http://web.crtg.io/base/crtg_items/create_cradmin_kala-1.0.pkg > /tmp/create_cradmin_kala-1.0.pkg
