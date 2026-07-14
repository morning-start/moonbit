--- 配置 MoonBit 所需的环境变量，并创建/更新 ~/.moon 软链接
--- 软链接始终指向当前激活的版本，切换版本时自动更新
--- 参考: https://vfox.dev/plugins/create/howto.html#envkeys
--- @param ctx table 上下文
--- @field ctx.path string SDK 安装目录
--- @return table[] 环境变量配置列表
function PLUGIN:EnvKeys(ctx)
    local file = require("file")
    local log = require("log")
    local mainPath = ctx.path
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    local moon_link = nil

    --- 运行宿主命令，跨平台兼容
    local function run_host_command(windows_cmd, unix_cmd)
        local cmd = require("cmd")
        local command = (RUNTIME.osType == "windows") and windows_cmd or unix_cmd
        return pcall(cmd.exec, command)
    end

    --- 创建/更新 ~/.moon 软链接指向当前版本
    if home then
        moon_link = file.join_path(home, ".moon")

        -- 检查是否已存在真实目录（非软链接），避免覆盖用户手动安装
        local is_real_dir = false
        if file.exists(moon_link) then
            -- Windows 上 rmdir 只能删除目录（不能删软链接）
            -- Unix 上 readlink 可判断是否软链接
            if RUNTIME.osType == "windows" then
                local ok = run_host_command(
                    'powershell -NoProfile -Command "if (-not (Get-Item \'' .. moon_link .. '\').Attributes -band [System.IO.FileAttributes]::ReparsePoint) { exit 1 }"',
                    ""
                )
                is_real_dir = not ok
            else
                local ok, _ = pcall(require("cmd").exec, 'readlink "' .. moon_link .. '"')
                is_real_dir = not ok
            end
        end

        if not file.exists(moon_link) then
            -- 不存在，直接创建
            local ok, err = pcall(file.symlink, mainPath, moon_link)
            if not ok then
                log.warn("创建 ~/.moon 软链接失败: " .. tostring(err))
                moon_link = nil
            end
        elseif is_real_dir then
            -- 已存在真实目录，不覆盖，警告用户
            log.warn("~/.moon 已存在且不是软链接，跳过创建。")
            log.warn("如需使用 mise 管理，请手动删除 ~/.moon 后重新安装。")
            moon_link = nil
        else
            -- 已存在软链接，更新指向
            local ok = run_host_command(
                'powershell -NoProfile -Command "Remove-Item -Force -Path \'' .. moon_link .. '\' -ErrorAction SilentlyContinue"',
                'rm -f "' .. moon_link .. '"'
            )
            if ok then
                ok, _ = pcall(file.symlink, mainPath, moon_link)
                if not ok then
                    log.warn("更新 ~/.moon 软链接失败")
                    moon_link = nil
                end
            else
                log.warn("删除旧 ~/.moon 软链接失败")
                moon_link = nil
            end
        end
    end

    return {
        {
            key = "MOON_HOME",
            value = moon_link or mainPath,
        },
        {
            key = "PATH",
            value = mainPath .. "/bin",
        },
    }
end