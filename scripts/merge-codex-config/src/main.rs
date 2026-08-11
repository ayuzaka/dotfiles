use std::{
    env, fs,
    io::{self, Write},
    os::unix::fs::PermissionsExt,
    path::{Path, PathBuf},
    process::ExitCode,
};

use tempfile::NamedTempFile;
use toml_edit::{DocumentMut, Item, Table};

// Codex が更新するため、dotfiles では管理しない Marketplace の状態値。
const MARKETPLACE_STATE_KEYS: [&str; 2] = ["last_updated", "last_revision"];

struct Arguments {
    check: bool,
    target: Option<PathBuf>,
}

fn parse_arguments() -> Result<Arguments, String> {
    let mut arguments = Arguments {
        check: false,
        target: None,
    };
    let mut values = env::args_os().skip(1);

    while let Some(value) = values.next() {
        match value.to_str() {
            Some("--check") => arguments.check = true,
            Some("--target") => {
                let target = values.next().ok_or("--target requires a path")?;
                arguments.target = Some(PathBuf::from(target));
            }
            Some("--help") | Some("-h") => {
                println!("Usage: merge-codex-config [--check] [--target PATH]");
                std::process::exit(0);
            }
            _ => return Err(format!("unknown argument: {}", value.to_string_lossy())),
        }
    }

    Ok(arguments)
}

fn home_directory() -> Result<PathBuf, String> {
    env::var_os("HOME")
        .map(PathBuf::from)
        .ok_or("HOME must be set".to_owned())
}

fn resolve_target(override_path: Option<PathBuf>) -> Result<PathBuf, String> {
    if let Some(path) = override_path {
        return Ok(path);
    }

    if let Some(codex_home) = env::var_os("CODEX_HOME") {
        return Ok(PathBuf::from(codex_home).join("config.toml"));
    }

    if let Some(xdg_config_home) = env::var_os("XDG_CONFIG_HOME") {
        return Ok(PathBuf::from(xdg_config_home).join("codex/config.toml"));
    }

    Ok(home_directory()?.join(".config/codex/config.toml"))
}

fn load_desired_config(repository_root: &Path) -> Result<DocumentMut, String> {
    let config_path = repository_root.join("extras/codex/config.toml");
    let config = fs::read_to_string(&config_path)
        .map_err(|error| format!("{}: {error}", config_path.display()))?;

    config
        .parse::<DocumentMut>()
        .map_err(|error| format!("{}: {error}", config_path.display()))
        .map(remove_system_managed_settings)
}

fn remove_system_managed_settings(mut desired: DocumentMut) -> DocumentMut {
    // Codex 自身が保持する状態は、テンプレートから取り除いてマージ対象外にする。
    if let Some(tui) = desired["tui"].as_table_mut() {
        tui.remove("model_availability_nux");
    }

    if let Some(marketplaces) = desired["marketplaces"].as_table_mut() {
        for (_, marketplace) in marketplaces.iter_mut() {
            if let Some(marketplace) = marketplace.as_table_mut() {
                for key in MARKETPLACE_STATE_KEYS {
                    marketplace.remove(key);
                }
            }
        }
    }

    desired
}

fn items_are_equal(current: &Item, desired: &Item) -> bool {
    let mut current_document = DocumentMut::new();
    current_document["setting"] = current.clone();
    let mut desired_document = DocumentMut::new();
    desired_document["setting"] = desired.clone();

    toml::from_str::<toml::Value>(&current_document.to_string()).ok()
        == toml::from_str::<toml::Value>(&desired_document.to_string()).ok()
}

fn merge_tables(destination: &mut Table, desired: &Table) {
    for (key, desired_item) in desired.iter() {
        match destination.get_mut(key) {
            // テーブル同士だけを再帰的にマージし、既存の未管理設定を残す。
            Some(current_item) if current_item.is_table() && desired_item.is_table() => {
                merge_tables(
                    current_item.as_table_mut().expect("table checked above"),
                    desired_item.as_table().expect("table checked above"),
                );
            }
            Some(current_item) if items_are_equal(current_item, desired_item) => {}
            _ => {
                destination.insert(key, desired_item.clone());
            }
        }
    }
}

fn validate_target(target: &Path) -> Result<(), String> {
    if target.is_symlink() {
        return Err(format!("refusing to replace symlink: {}", target.display()));
    }
    if target.exists() && !target.is_file() {
        return Err(format!(
            "target is not a regular file: {}",
            target.display()
        ));
    }
    Ok(())
}

fn write_atomically(target: &Path, content: &str) -> io::Result<()> {
    let parent = target.parent().ok_or_else(|| {
        io::Error::new(
            io::ErrorKind::InvalidInput,
            format!("target has no parent: {}", target.display()),
        )
    })?;
    fs::create_dir_all(parent)?;

    // 同一ディレクトリの一時ファイルを置換し、途中まで書かれた設定を残さない。
    let mut temporary = NamedTempFile::new_in(parent)?;
    temporary.write_all(content.as_bytes())?;
    temporary.as_file().sync_all()?;
    fs::set_permissions(temporary.path(), fs::Permissions::from_mode(0o600))?;
    temporary.persist(target).map_err(|error| error.error)?;
    Ok(())
}

fn run() -> Result<ExitCode, String> {
    let arguments = parse_arguments()?;
    let repository_root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .and_then(Path::parent)
        .ok_or("unable to find repository root")?;
    let target = resolve_target(arguments.target)?;
    validate_target(&target)?;

    let desired = load_desired_config(repository_root)?;
    let (original, mut merged, current_mode) = if target.exists() {
        let original = fs::read_to_string(&target)
            .map_err(|error| format!("{}: {error}", target.display()))?;
        let merged = original
            .parse::<DocumentMut>()
            .map_err(|error| format!("{}: {error}", target.display()))?;
        let mode = fs::metadata(&target)
            .map_err(|error| format!("{}: {error}", target.display()))?
            .permissions()
            .mode()
            & 0o777;
        (original, merged, Some(mode))
    } else {
        (String::new(), DocumentMut::new(), None)
    };

    merge_tables(merged.as_table_mut(), desired.as_table());
    let rendered = merged.to_string();
    let needs_update = rendered != original || current_mode != Some(0o600);

    if arguments.check {
        if needs_update {
            println!("Codex config needs update: {}", target.display());
            return Ok(ExitCode::from(1));
        }
        println!("Codex config is up to date: {}", target.display());
        return Ok(ExitCode::SUCCESS);
    }

    if rendered != original {
        write_atomically(&target, &rendered)
            .map_err(|error| format!("{}: {error}", target.display()))?;
        println!("Merged Codex config: {}", target.display());
    } else if current_mode != Some(0o600) {
        fs::set_permissions(&target, fs::Permissions::from_mode(0o600))
            .map_err(|error| format!("{}: {error}", target.display()))?;
        println!("Updated Codex config permissions: {}", target.display());
    } else {
        println!("Codex config is up to date: {}", target.display());
    }

    Ok(ExitCode::SUCCESS)
}

fn main() -> ExitCode {
    match run() {
        Ok(exit_code) => exit_code,
        Err(error) => {
            eprintln!("merge-codex-config: {error}");
            ExitCode::from(2)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn preserves_unmanaged_projects_and_codex_state() {
        let mut destination = r#"
model = "old-model"

[projects."/private/project"]
trust_level = "trusted"

[marketplaces.example]
last_updated = "2026-08-01T00:00:00Z"
source = "https://example.com/original.git"
"#
        .parse::<DocumentMut>()
        .unwrap();
        let desired = r#"
model = "new-model"

[marketplaces.example]
last_updated = "managed-value"
source = "https://example.com/managed.git"
"#
        .parse::<DocumentMut>()
        .map(remove_system_managed_settings)
        .unwrap();

        merge_tables(destination.as_table_mut(), desired.as_table());

        assert_eq!(destination["model"].as_str(), Some("new-model"));
        assert_eq!(
            destination["projects"]["/private/project"]["trust_level"].as_str(),
            Some("trusted")
        );
        assert_eq!(
            destination["marketplaces"]["example"]["last_updated"].as_str(),
            Some("2026-08-01T00:00:00Z")
        );
        assert_eq!(
            destination["marketplaces"]["example"]["source"].as_str(),
            Some("https://example.com/managed.git")
        );
    }
}
