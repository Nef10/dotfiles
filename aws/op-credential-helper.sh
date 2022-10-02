#!/usr/bin/env zsh

secret_id="$1"

cat <<END | op inject
{
  "Version": 1,
  "AccessKeyId": "{{ op://Personal/${secret_id}/username }}",
  "SecretAccessKey": "{{ op://Personal/${secret_id}/credential }}"
}
END
