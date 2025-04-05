```console
$ ./scripts/manage/inspect-autoscaling.shell ;
```

```console
[Inspecting Autoscaling in Workspace: dev]
[Target Configuration: ./configs/targets/dev.json]
-rw-r--r--@ 1 emvaldes  staff  221 Apr  4 13:06 ./configs/targets/dev.json
```

```json
{
    "id": "dev",
    "name": "development",
    "description": "Development environment",
    "region": "west",
    "type": "micro",
    "policies": {
        "autoscaling": "basic",
        "stressload": "low"
    }
}
```

```console
[Policies Configuration: ./configs/policies.json]
-rw-r--r--@ 1 emvaldes  staff  1895 Apr  4 20:06 ./configs/policies.json

[Target Configuration: ./configs/targets/dev.json]

[Stressload Key: low]
[Stressload Configuration: {
  "duration": 60,
  "threads": 250,
  "interval": 0.04,
  "requests": 10000
}]

[Stressload Duration: 60]
[Stressload Concurrency: 250]
[Stressload Interval: 0.04]
[Stressload Requests: 10000]

[Phase Duration: 15]
[Load Balancer IP: 34.8.19.233]
[Target URL: http://34.8.19.233]
[GCP Project ID: static-lead-454601-q1]
[GCP Region: us-west2]
[Managed Instance Group: https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/regions/us-west2/instanceGroups/dev--web-servers-group]
[MIG Name: dev--web-servers-group]

[Autoscaling Key: basic]
[Autoscaling Configuration: {
  "min": 1,
  "max": 2,
  "threshold": 0.6,
  "cooldown": 60
}]
[Autoscaling Minimum: 1]

Running stress test against: http://34.8.19.233
Stress Level: low | Threads: 250 | Duration: 60s | Interval: 0.04s | Requests: 10000
[Phase: Burst Load] Duration: 15s | Concurrency: 500

[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 1
```

```json
[
  {
    "currentAction": "NONE",
    "id": "1747512472322793130",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/instances/dev--web-server-bn6l",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-bn6l",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  }
]
```

```console
Summary:

  Total:	15.0719 secs
  Slowest:	2.6772 secs
  Fastest:	0.0166 secs
  Average:	0.0677 secs
  Requests/sec:	7366.0350

  Total data:	6890065 bytes
  Size/request:	62 bytes

Response time histogram:
  0.017 [1]	|
  0.283 [109827]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.549 [844]	|
  0.815 [176]	|
  1.081 [112]	|
  1.347 [30]	|
  1.613 [8]	|
  1.879 [7]	|
  2.145 [7]	|
  2.411 [0]	|
  2.677 [8]	|


Latency distribution:
  10% in 0.0235 secs
  25% in 0.0266 secs
  50% in 0.0797 secs
  75% in 0.0897 secs
  90% in 0.0961 secs
  95% in 0.1011 secs
  99% in 0.3154 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0003 secs, 0.0166 secs, 2.6772 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0003 secs
  resp wait:	0.0669 secs, 0.0166 secs, 2.6771 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0013 secs

Status code distribution:
  [200]	109775 responses
  [502]	1245 responses
```

```console
[Phase: Sustained Pressure] Duration: 15s | Concurrency: 250

[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 1
```

```json
[
  {
    "currentAction": "NONE",
    "id": "1747512472322793130",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/instances/dev--web-server-bn6l",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-bn6l",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  }
]
```

```console
Summary:

  Total:	15.0322 secs
  Slowest:	1.1089 secs
  Fastest:	0.0163 secs
  Average:	0.0341 secs
  Requests/sec:	7326.8821

  Total data:	6681111 bytes
  Size/request:	60 bytes

Response time histogram:
  0.016 [1]	|
  0.126 [107236]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.235 [2653]	|■
  0.344 [128]	|
  0.453 [49]	|
  0.563 [45]	|
  0.672 [6]	|
  0.781 [15]	|
  0.890 [3]	|
  1.000 [0]	|
  1.109 [3]	|


Latency distribution:
  10% in 0.0230 secs
  25% in 0.0251 secs
  50% in 0.0278 secs
  75% in 0.0320 secs
  90% in 0.0385 secs
  95% in 0.0651 secs
  99% in 0.1736 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0002 secs, 0.0163 secs, 1.1089 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0002 secs
  resp wait:	0.0339 secs, 0.0163 secs, 1.1089 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0006 secs

Status code distribution:
  [200]	109469 responses
  [502]	670 responses
```

```console
[Phase: Cooldown] Duration: 15s | Concurrency: 125

[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 2
```

```json
[
  {
    "currentAction": "NONE",
    "id": "4948940550269916065",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-a/instances/dev--web-server-n1k6",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-n1k6",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  },
  {
    "currentAction": "NONE",
    "id": "1747512472322793130",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/instances/dev--web-server-bn6l",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-bn6l",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  }
]
```

```console
Summary:

  Total:	15.0303 secs
  Slowest:	0.1812 secs
  Fastest:	0.0166 secs
  Average:	0.0275 secs
  Requests/sec:	4540.3055

  Total data:	4032011 bytes
  Size/request:	59 bytes

Response time histogram:
  0.017 [1]	|
  0.033 [66751]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.050 [1058]	|■
  0.066 [306]	|
  0.082 [0]	|
  0.099 [0]	|
  0.115 [1]	|
  0.132 [50]	|
  0.148 [22]	|
  0.165 [35]	|
  0.181 [18]	|


Latency distribution:
  10% in 0.0233 secs
  25% in 0.0258 secs
  50% in 0.0274 secs
  75% in 0.0287 secs
  90% in 0.0301 secs
  95% in 0.0312 secs
  99% in 0.0458 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0001 secs, 0.0166 secs, 0.1812 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0002 secs
  resp wait:	0.0274 secs, 0.0166 secs, 0.1812 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0003 secs

Status code distribution:
  [200]	68221 responses
  [502]	21 responses
```

```console
[Phase: Recovery] Duration: 15s | Concurrency: 62

[Inspecting Instances in MIG: dev--web-servers-group]
Current instances running: 2
```

```json
[
  {
    "currentAction": "NONE",
    "id": "4948940550269916065",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-a/instances/dev--web-server-n1k6",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-n1k6",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  },
  {
    "currentAction": "NONE",
    "id": "1747512472322793130",
    "instance": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/zones/us-west2-c/instances/dev--web-server-bn6l",
    "instanceStatus": "RUNNING",
    "name": "dev--web-server-bn6l",
    "version": {
      "instanceTemplate": "https://www.googleapis.com/compute/v1/projects/static-lead-454601-q1/global/instanceTemplates/dev--web-server-template--20250405074759047200000001"
    }
  }
]
```

```console
Summary:

  Total:	15.0250 secs
  Slowest:	0.1129 secs
  Fastest:	0.0167 secs
  Average:	0.0270 secs
  Requests/sec:	2293.7739

  Total data:	2033376 bytes
  Size/request:	59 bytes

Response time histogram:
  0.017 [1]	|
  0.026 [12181]	|■■■■■■■■■■■■■■■■■■■■■■
  0.036 [22017]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.046 [191]	|
  0.055 [12]	|
  0.065 [0]	|
  0.074 [9]	|
  0.084 [2]	|
  0.094 [13]	|
  0.103 [19]	|
  0.113 [19]	|


Latency distribution:
  10% in 0.0222 secs
  25% in 0.0254 secs
  50% in 0.0276 secs
  75% in 0.0287 secs
  90% in 0.0300 secs
  95% in 0.0306 secs
  99% in 0.0341 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0001 secs, 0.0167 secs, 0.1129 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0008 secs
  resp wait:	0.0269 secs, 0.0167 secs, 0.0567 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0011 secs

Status code distribution:
  [200]	34464 responses
```

```console
Stressload test complete.
```
