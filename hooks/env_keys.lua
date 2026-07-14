--- 配置 MoonBit 所需的环境变量
--- 并在版本切换时静默更新 ~/.moon 软链接指向当前版本
--- 参考: https://vfox.dev/plugins/create/howto.html#envkeys
--- @param ctx table 上下文
--- @field ctx.path string SDK 安装目录
--- @return table[] 环境变量配置列表
function PLUGIN:EnvKeys(ctx)
    local file = require("file")
    local mainPath = ctx.path
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")

    -- 静默更新 ~/.moon 软链接指向当前版本
    -- 安装时 post_install 已创建，此处仅处理版本切换时的更新
    -- 失败时静默回退，不报 warn
    if home then
        local moon_link = file.join_path(home, ".moon")
        local should_update = false

        if not file.exists(moon_link) then
            should_update = true
        else
            -- 检查是否已是软链接（而非真实目录），是则更新
            local is_symlink = false
            if RUNTIME.osType == "windows" then
                local ok = pcall(require("cmd").exec,
                    'powershell -NoProfile -Command "if ((Get-Item \'' .. moon_link .. '\').Attributes -band [System.IO.FileAttributes]::ReparsePoint) { exit 0 } else { exit 1 }"')
                is_symlink = ok
            else
                local ok, _ = pcall(require("cmd").exec, 'readlink "' .. moon_link .. '"')
                is_symlink = ok
            end
            if is_symlink then
                -- 删除旧软链接
                pcall(require("cmd").exec,
                    (RUNTIME.osType == "windows") and
                        'powershell -NoProfile -Command "Remove-Item -Force -Path \'' .. moon_link .. '\' -ErrorAction SilentlyContinue"' or
                        'rm -f "' .. moon_link .. '"')
                should_update = true
            end
        end

        if should_update then
            if RUNTIME.osType == "windows" then
                pcall(require("cmd").exec,
                    'cmd /c mklink /J "' .. moon_link .. '" "' .. mainPath .. '" 2>nul')
            else
                pcall(file.symlink, mainPath, moon_link)
            end
        end
    end

    return {
        {
            key = "MOON_HOME",
            value = mainPath,
        },
        {
            key = "PATH",
            value = mainPath .. "/bin",
        },
    }
end