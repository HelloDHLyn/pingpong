# Pingpong

> Activeness & serverless health check API

## Prerequistes

- apex ([link](http://apex.run))
- terraform ([link](https://terraform.io))

## Setup

```bash
# Initialize frameworks.
# If you want to start with existing project, copy `project.json` and `*.tfstate` files.
apex init
apex infra init

# Plan & apply DynamoDB.
apex infra plan -target=module.phase0
apex infra apply -target=module.phase0

# Depoly lambda functions.
apex deploy -D
apex deploy

# Plan & apply another AWS services.
apex infra plan -target=module.phase1
apex infra apply -target=module.phase1
```

## Usage

In your system, send HTTP post request alike below.

```bash
curl -X POST -H 'Content-Type: application/json' -d '{"service_name": "YOUR_SERVICE_NAME"}' https://YOUR_API_GATEWAY_HOST/ping
```

CloudWatch will automatically check delays, and notify you when some delays over threshold.

## Environment variables

You need to set some environment variables on `project.json` file.

- `MAX_DELAY_SECONDS` : Threshold for delay in seconds. (default: `300`)
- `SLACK_URL`(optional) : Slack webhook url. If exists, alert will be send to your slack.
