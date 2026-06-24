class Memcp < Formula
  desc "Cross-session persistent memory MCP server for coding agents"
  homepage "https://github.com/helixerio/memcp"
  version "1.5.6"

  on_macos do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456422547",
        header: [
          "Authorization: Bearer #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}",
          "Accept: application/octet-stream",
        ]
      sha256 "16623107f3070697017a844cae4f2be4b2d45c630822fd1891a58cbf54c1bb98"
    end
  end

  on_linux do
    on_arm do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456423436",
        header: [
          "Authorization: Bearer #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}",
          "Accept: application/octet-stream",
        ]
      sha256 "4e826af4e8831cd56071cc2c2ae4a7f916054b63bd47a4656c13cfdd1f64bb20"
    end

    on_intel do
      url "https://api.github.com/repos/helixerio/memcp/releases/assets/456423444",
        header: [
          "Authorization: Bearer #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}",
          "Accept: application/octet-stream",
        ]
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
    assert_match "memcp version: #{version}", shell_output("#{bin}/memcp version")
  end
end
