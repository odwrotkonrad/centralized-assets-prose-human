# infra

The `restricted` group and the sandbox identity it holds, as Terraform.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Two concerns, one state

- **Group tree** — `tf/terraform.tfvars` + `tf/levels.tf` + `tf/modules/level`, the
  same `level` pattern as `infra/git-repos`, trimmed (no GitHub mirror, no local
  runner). The `restricted` root group is UI-created and imported (`parent_id =
  null`); Terraform owns its `infra` project and branch protection.
- **Identity/secrets** — `tf/gitlab-token.tf`, `tf/ssh-key.tf`,
  `tf/gcp-identity.tf`, `tf/secrets.tf`: the `konradodwrot` group token, the
  sandbox SSH key, the restricted GCP SA, and the two Secrets Manager secrets the
  sandbox reads.

Both share one state in the separate `konradodwrot/restricted-tfstate` GCS
bucket, isolated from git-repos at the storage boundary.

## State bucket bootstrap (one-time)

The state bucket must exist before `make init` — a bucket cannot hold the state
that creates it. Create it out-of-band, applied by your own identity:

```sh
gcloud storage buckets create gs://konradodwrot/restricted-tfstate \
  --project=main-493613 --location=EU --uniform-bucket-level-access
```

Lock its IAM to your identity (and the restricted CI identity if CI applies).

## First apply

```sh
make init                 # binds to konradodwrot/restricted-tfstate
# import the UI-created group and (if pre-created) the infra project:
terraform -chdir=tf import 'module.l0.gitlab_group.this["restricted"]' 203029
make validate && make plan && make apply
```

## Sandbox SA key into 1Password (terraform-managed)

`tf/modules/auth/sandbox/op.tf` writes the SA key JSON into the
`SandboxProgrammaticAccess` vault (item `sandbox-gcp-sa`, field `sa_key`) on
every apply, no manual `op item edit`. Prerequisites, one-time, manual:

- 1P vault `SandboxProgrammaticAccess`, your own write access kept.
- A 1P service account with write access to that vault only, its token passed
  as `TF_VAR_op_service_account_token`.
- A billing account id for the `konradodwrot-sandbox-auth` project, passed as
  `TF_VAR_gcp_billing_account`.
- Applies creating the GCP folder tree/project run locally with your own
  gcloud identity (org-level perms); the CI applier SA has none.
- `TF_VAR_op_service_account_token` and `TF_VAR_gcp_billing_account` are
  self-managed CI variables (protected + masked, `group-vars.tf`): the first
  apply runs locally with both exported, which lands them on the iac project
  for every later CI plan/apply. All iac refs are protected
  (`protect_all_branches`), so they flow to MR-branch plan jobs too.

## Apt signing key (terraform-managed)

`tf/modules/auth/release-signing` generates the apt signing GPG key
(`Olivr/gpg`, RSA 4096) and its passphrase (`random_password`, 32 alphanumeric
chars, maskable by construction), writes both plus the public key into op item
`apt-signing-gpg` in `SandboxProgrammaticAccess` as a durable record, and pipes
them into `konradodwrot/go-modules` as protected CI variables
(`APT_GPG_PRIVATE_KEY` file-type, `APT_GPG_PASSPHRASE` masked). The key
resource carries `prevent_destroy`: replacing it breaks every installed apt
client until they re-fetch `gpg.key`, so rotation must be an explicit state
operation, never a plan side effect.

## CI variables (self-managed)

`tf/modules/gitlab/group-vars.tf` manages the iac project's own CI variables:
`TF_GITLAB_TOKEN` (the CI applier's gitlab token, not the sandbox token),
`GITHUB_TOKEN` (push-mirror token), `GOOGLE_CREDENTIALS` (base64 applier SA
key), `TF_VAR_op_service_account_token` and `TF_VAR_gcp_billing_account`. All
masked; values enter the (storage-isolated) restricted state.

Their source inputs are required, with no empty defaults: an apply without
them would blank the live CI variables (and `github_token` would rewrite every
push-mirror URL without a credential). CI feeds them back to itself via
`.gitlab-ci.yml` variable mappings (`TF_VAR_ci_gitlab_token: $TF_GITLAB_TOKEN`,
…); local applies must export them:

```sh
export TF_VAR_github_token=…             # github PAT (mirror URLs + GITHUB_TOKEN CI variable)
export TF_VAR_ci_gitlab_token=…          # current TF_GITLAB_TOKEN value
export TF_VAR_ci_google_credentials=…    # current GOOGLE_CREDENTIALS value
export TF_VAR_op_service_account_token=…
export TF_VAR_gcp_billing_account=…
```

Read current values as a maintainer via
`glab variable get <KEY> -R konradodwrot/cross-repo/infra/iac`.

## Token isolation

The `konradodwrot` group token has zero reach into `restricted` (separate root
group). Prove it: `GITLAB_TOKEN=<token> glab api groups/restricted` returns
403/404.

## License

[MIT](LICENSE)
