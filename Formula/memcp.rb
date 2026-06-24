require "utils/github"

class GitHubReleaseAssetDownloadStrategy < AbstractFileDownloadStrategy
  def initialize(url, name, version, **meta)
    @asset_name = meta.fetch(:asset_name)
    super
  end

  def fetch(timeout: nil)
    token = GitHub::API.credentials.to_s
    if token.empty?
      raise CurlDownloadStrategyError.new(
        url,
        "GitHub credentials are required; run `gh auth login` or set HOMEBREW_GITHUB_API_TOKEN",
      )
    end

    ohai "Downloading #{url}"
    if cached_location.exist?
      puts "Already downloaded: #{cached_location}"
    else
      begin
        Utils::Curl.curl_download(
          url,
          to:      temporary_path,
          header:  [
            "Authorization: Bearer #{token}",
            "Accept: application/octet-stream",
          ],
          secrets: [token],
          timeout:,
        )
      rescue ErrorDuringExecution => e
        raise CurlDownloadStrategyError.new(url, e.stderr.strip)
      end
      cached_location.dirname.mkpath
      temporary_path.rename(cached_location.to_s)
    end

    create_symlink_to_cached_download(cached_location)
  end

  private

  def resolved_basename
    @asset_name
  end
end

class Memcp < Formula
  desc "Cross-session persistent memory MCP server for coding agents"
  homepage "https://github.com/helixerio/memcp"
  version "1.5.7"

  on_macos do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456450147",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.7-darwin-arm64.zip"
      sha256 "7d15d694bcace1661cf529d1e089451dc4119d1e7e643101e6b5516f5e98ebd1"
    end
  end

  on_linux do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456451367",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.7-linux-arm64.zip"
      sha256 "c32aa84740df1a49a954ce7b38d2da66a4f6b57fe63d1b912c621fa095a98854"
    end

    on_intel do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456451352",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.7-linux-amd64.zip"
      sha256 "bf7bf13fec3f3572cc1db32ff826b3a986bc73df175c3c384a0907b76592cb56"
    end
  end

  def install
    bin.install "memcp"
  end

  service do
    run [opt_bin/"memcp", "serve"]
    keep_alive true
    log_path var/"log/memcp.log"
    error_log_path var/"log/memcp.log"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      To run memcp as a background service:

        brew services start memcp

      This starts `memcp serve` on http://127.0.0.1:19522 with:
        - MCP endpoint at /mcp (for Claude Desktop, OpenCode, etc.)
        - Web dashboard at /
        - REST API at /api/*

      Data is stored at ~/.local/share/memcp/memories.db

      To configure MCP clients, use the HTTP transport URL:
        http://127.0.0.1:19522/mcp
    EOS
  end

  test do
    assert_match "memcp version: v#{version}", shell_output("#{bin}/memcp version")
  end
end
