##[>] 🤖🤖
ARTIFACT_REGISTRY={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_ARTIFACT_REGISTRY" }}
CI_IMAGES_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CI_IMAGES_REF" }}
CHE_PACKAGES_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CHE_PACKAGES_REF" }}
GITLAB_TOKEN={{ secret "op://ProgrammaticAccess/gitlab/access_token" }}
GOOGLE_CREDENTIALS={{ secret "op://ProgrammaticAccess/gcp/credentials_json" }}
##[<] 🤖🤖
