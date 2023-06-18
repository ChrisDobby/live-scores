# Live Cricket Scores

## Introduction

This is the monorepo for the Live Cricket Scores Service. This service is built using an AWS event driven architecture to find HTML scorecards and publish updates to S3, web sockets, webpush whenever the scores are updated.

Source code is found under the `packages/` directory:

- `functions` for lambda functions entry points
- `libs` for common libraries that are used by apps
- `scorecard-processor` for the scorecard processor process

## Installation

This repo makes use of [Turbo Repo](https://turborepo.org/) and NPM workspaces to aid with monorepo setup.

Install:
`npm i`

Dependencies between commands can also be found in `turbo.json`

## Architecture Diagram

![Architecture](./architecture.drawio.png)

## Deployment

The service is deployed using [Terraform](https://www.terraform.io/). The definitions can be found in the `terraform` directory and the service is deployed by the `deploy.yml` GHA workflow every time main is updated.

The deployment workflow requires the following secrets in the Github repository:

- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `SANITY_EDIT_TOKEN` - edit token for updating the result in [Sanity](https://www.sanity.io/). Disable updating Sanity by throttling the `update-sanity` lambda
- `API_KEY` - API key for the API endpoints to subscribe to score and socket updates
- `VAPID_SUBJECT` - Webpush Vapid subject. Disable webpush by throttling the `web-notify` lambda
- `VAPID_PUBLIC_KEY` - Webpush Vapid public key. Disable webpush by throttling the `web-notify` lambda
- `VAPID_PRIVATE_KEY` - Webpush Vapid private key. Disable webpush by throttling the `web-notify` lambda

Vapid keys can be created [here](
https://vapidkeys.com)
