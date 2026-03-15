function npm_package_github_repo() {
  local package_name repository_url repo_path

  package_name="$1"
  if [[ -z "$package_name" ]]; then
    echo "usage: npm-package-github-repo <package_name>" >&2
    return 1
  fi

  repository_url="$(npm view "$package_name" repository.url 2>/dev/null)"
  if [[ -z "$repository_url" ]]; then
    return 1
  fi

  repo_path="${repository_url#git+https://github.com/}"
  repo_path="${repo_path#https://github.com/}"
  repo_path="${repo_path%.git}"

  if [[ "$repo_path" == "$repository_url" ]]; then
    return 1
  fi

  echo "$repo_path"
}

function npm_package_github_stars() {
  local package_name repo_path

  package_name="$1"
  if [[ -z "$package_name" ]]; then
    echo "usage: npm-package-github-stars <package_name>" >&2
    return 1
  fi

  repo_path="$(npm_package_github_repo "$package_name")" || return 1
  gh repo view "$repo_path" --json stargazerCount --jq '.stargazerCount'
}

function npm_package_github_security_advisories() {
  local package_name repo_path

  package_name="$1"
  if [[ -z "$package_name" ]]; then
    echo "usage: npm_package_github_security_advisories <package_name>" >&2
    return 1
  fi

  repo_path="$(npm_package_github_repo "$package_name")" || return 1
  gh api "repos/$repo_path/security-advisories" --jq '.[] | {ghsa: .ghsa_id, severity, summary}'
}

function _npm_package_git_root() {
  local dir

  dir="$PWD"
  while true; do
    if [[ -e "$dir/.git" ]]; then
      echo "$dir"
      return 0
    fi

    [[ "$dir" == "/" ]] && return 1
    dir="${dir:h}"
  done
}

function _npm_package_release_age_minutes() {
  local git_root current_dir config_dir package_manager raw_age

  git_root="$(_npm_package_git_root)" || return 1
  current_dir="$PWD"

  while true; do
    if [[ -f "$current_dir/pnpm-workspace.yaml" ]]; then
      config_dir="$current_dir"
      package_manager="pnpm"
      break
    fi

    if [[ -f "$current_dir/.yarnrc.yml" ]]; then
      config_dir="$current_dir"
      package_manager="yarn"
      break
    fi

    if [[ -f "$current_dir/.npmrc" ]]; then
      config_dir="$current_dir"
      package_manager="npm"
      break
    fi

    [[ "$current_dir" == "$git_root" ]] && return 1
    current_dir="${current_dir:h}"
  done

  case "$package_manager" in
    pnpm)
      raw_age="$(cd "$config_dir" && pnpm config get minimumReleaseAge 2>/dev/null)"
      ;;
    yarn)
      raw_age="$(cd "$config_dir" && yarn config get npmMinimalAgeGate 2>/dev/null)"
      ;;
    npm)
      raw_age="$(cd "$config_dir" && npm config get min-release-age 2>/dev/null)"
      ;;
    *)
      return 1
      ;;
  esac

  case "$raw_age" in
    ""|0|null|undefined)
      return 1
      ;;
  esac

  [[ "$raw_age" =~ '^[0-9]+$' ]] || return 1
  echo "$raw_age"
}

function npm_package_latest_version() {
  local package_name age_minutes latest_version include_prerelease

  package_name="$1"
  include_prerelease=0

  case "$2" in
    --include-prerelease)
      include_prerelease=1
      ;;
    "")
      ;;
    *)
      echo "usage: npm_package_latest_version <package_name> [--include-prerelease]" >&2
      return 1
      ;;
  esac

  if [[ -z "$package_name" ]]; then
    echo "usage: npm_package_latest_version <package_name> [--include-prerelease]" >&2
    return 1
  fi

  age_minutes="$(_npm_package_release_age_minutes)"

  latest_version="$(
    npm view "$package_name" time --json 2>/dev/null \
      | node -e '
          const fs = require("node:fs");

          const ageMinutes = process.argv[1];
          const includePrerelease = process.argv[2] === "1";
          const threshold = ageMinutes === "" ? Infinity : Date.now() - Number(ageMinutes) * 60 * 1000;
          const input = fs.readFileSync(0, "utf8").trim();
          if (!input) {
            process.exit(1);
          }

          const timeMap = JSON.parse(input);
          for (const [version, publishedAt] of Object.entries(timeMap)) {
            if (!/^[0-9]/.test(version)) continue;
            if (!includePrerelease && version.includes("-")) continue;

            const published = Date.parse(publishedAt);
            if (!Number.isFinite(published)) continue;
            if (published <= threshold) {
              console.log(version);
            }
          }
        ' "$age_minutes" "$include_prerelease" \
      | sort -V \
      | tail -n1
  )" || return 1

  [[ -n "$latest_version" ]] || return 1
  echo "$latest_version"
}
