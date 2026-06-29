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
  version "1.5.8"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/memcp-1.5.8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "c6ebca4e6b3777e3d1eac5bb48d192819861d63d1a9862481dd1e4cc417b5b2e"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "f658ead87d280f9a09f1c1446626e817a61a473c6589bd56fe794c1dec3eafa0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9d240ab5e069aaf543ef379e58fa280ed3d718502f7dde2ed2302d7219a98566"
  end

  on_macos do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/460428653",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.8-darwin-arm64.zip"
      sha256 "37c3351301948865b033b337fb4bb8815d156094dfb60a5971c4dc4a1aed7810"
    end
  end

  on_linux do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/460429382",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.8-linux-arm64.zip"
      sha256 "942ca065d714e00e8a024c949a33e89ca9040565d98f79914d93494d78dd3d45"
    end

    on_intel do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/460429376",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.8-linux-amd64.zip"
      sha256 "79980681b18bd493f3ff26bc0eec1810fceaec36ad06c87ec6f3ec8713f0df85"
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
