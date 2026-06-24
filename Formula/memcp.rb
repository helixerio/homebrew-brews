class GitHubReleaseAssetDownloadStrategy < AbstractFileDownloadStrategy
  def initialize(url, name, version, **meta)
    @asset_name = meta.fetch(:asset_name)
    super
  end

  def fetch(timeout: nil)
    token = ENV["HOMEBREW_GITHUB_API_TOKEN"].to_s
    raise CurlDownloadStrategyError.new(url, "HOMEBREW_GITHUB_API_TOKEN is required") if token.empty?

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
  version "1.5.6"

  on_macos do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456422547",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.6-darwin-arm64.zip"
      sha256 "16623107f3070697017a844cae4f2be4b2d45c630822fd1891a58cbf54c1bb98"
    end
  end

  on_linux do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456423436",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.6-linux-arm64.zip"
      sha256 "4e826af4e8831cd56071cc2c2ae4a7f916054b63bd47a4656c13cfdd1f64bb20"
    end

    on_intel do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456423444",
        using:      GitHubReleaseAssetDownloadStrategy,
        asset_name: "memcp-v1.5.6-linux-amd64.zip"
      sha256 "3e1c16b13b68e4b946a7ca2ce6c8a35f9c6d324be39c45ee3dfed0774105261d"
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
