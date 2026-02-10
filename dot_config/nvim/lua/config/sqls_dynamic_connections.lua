local M = {}

local placeholder_password = "__SQLS_OP_SECRET_PLACEHOLDER__"

local is_op_ref = function(password)
    return type(password) == "string" and vim.startswith(password, "op://")
end

local collect_op_refs = function(configs)
    local refs = {}
    local seen = {}
    for _, config in ipairs(configs) do
        if is_op_ref(config.password) and not seen[config.password] then
            table.insert(refs, config.password)
            seen[config.password] = true
        end
    end
    return refs
end

local read_op_secrets = function(op_refs)
    if #op_refs == 0 then
        return {}, nil
    end

    local script = [[
for ref in "$@"; do
  printf '__SQLS_OP_REF__%s\n' "$ref"
  op read "$ref" || exit 1
  printf '\n__SQLS_OP_END__\n'
done
]]

    local cmd = { "op", "run", "--", "sh", "-c", script, "sh" }
    for _, ref in ipairs(op_refs) do
        table.insert(cmd, ref)
    end

    local result = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        return nil, "op run failed"
    end

    local secrets = {}
    local current_ref = nil
    local current_lines = {}

    for _, line in ipairs(result) do
        local ref = line:match("^__SQLS_OP_REF__(.+)$")
        if ref then
            current_ref = ref
            current_lines = {}
        elseif line == "__SQLS_OP_END__" then
            if current_ref then
                local secret = vim.trim(table.concat(current_lines, "\n"))
                if secret == "" then
                    return nil, string.format("empty secret: %s", current_ref)
                end
                secrets[current_ref] = secret
            end
            current_ref = nil
            current_lines = {}
        elseif current_ref then
            table.insert(current_lines, line)
        end
    end

    return secrets, nil
end

local build_mysql_connection = function(config, op_secrets, allow_placeholder)
    if not config.password or config.password == "" then
        vim.notify(
            string.format("パスワードが未設定です(%s)", config.alias),
            vim.log.levels.WARN
        )
        return nil
    end

    local password = config.password
    if is_op_ref(config.password) then
        password = op_secrets[config.password]
        if (not password or password == "") and allow_placeholder then
            password = placeholder_password
        end
    end

    if not password or password == "" then
        vim.notify(
            string.format("1Passwordの秘密参照が取得できませんでした(%s)", config.alias),
            vim.log.levels.WARN
        )
        return nil
    end

    return {
        alias = config.alias,
        driver = "mysql",
        dataSourceName = string.format(
            "%s:%s@tcp(%s:%s)/%s",
            config.user,
            password,
            config.host,
            config.port,
            config.database
        ),
        sshConfig = config.sshConfig or config.sshconfig,
    }
end

local function patch_sqls_switch_connection(load_mysql_connections)
    local ok, sqls_commands = pcall(require, "sqls.commands")
    if not ok then
        return false
    end

    if sqls_commands._sqls_switch_patched_by_local_config then
        return true
    end

    local original_switch_connection = sqls_commands.switch_connection
    sqls_commands.switch_connection = function(client_id, query)
        load_mysql_connections()
        return original_switch_connection(client_id, query)
    end
    sqls_commands._sqls_switch_patched_by_local_config = true

    return true
end

M.setup = function(opts)
    local connection_configs = opts.connection_configs or {}

    local mysql_configs = {}
    for _, config in ipairs(connection_configs) do
        if config.driver == "mysql" then
            table.insert(mysql_configs, config)
        end
    end

    local rebuild_connections = function(op_secrets, allow_placeholder)
        local next_connections = {}
        for _, config in ipairs(connection_configs) do
            if config.driver == "mysql" then
                local mysql_connection = build_mysql_connection(config, op_secrets or {}, allow_placeholder)
                if mysql_connection then
                    table.insert(next_connections, mysql_connection)
                end
            else
                table.insert(next_connections, config)
            end
        end
        return next_connections
    end

    local connections = rebuild_connections({}, true)

    local apply_sqls_config = function()
        local settings = {
            settings = {
                sqls = {
                    connections = connections,
                },
            },
        }
        vim.lsp.config("sqls", settings)
        for _, client in ipairs(vim.lsp.get_clients({ name = "sqls" })) do
            client.config.settings = settings.settings
            client.notify("workspace/didChangeConfiguration", {
                settings = settings.settings,
            })
        end
    end

    local mysql_loaded = false
    local load_mysql_connections = function()
        if mysql_loaded then
            return
        end

        local op_refs = collect_op_refs(mysql_configs)
        local op_secrets, err = read_op_secrets(op_refs)
        if not op_secrets then
            vim.notify(
                string.format("1Passwordの秘密参照が取得できませんでした: %s", err),
                vim.log.levels.WARN
            )
            return
        end

        connections = rebuild_connections(op_secrets, false)
        mysql_loaded = true
        apply_sqls_config()
    end

    apply_sqls_config()
    patch_sqls_switch_connection(load_mysql_connections)

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("sqls-switch-hook", { clear = true }),
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "sqls" then
                patch_sqls_switch_connection(load_mysql_connections)
            end
        end,
    })
end

return M
