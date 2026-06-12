class Memcp < Formula
  desc "Cross-session persistent memory MCP server for coding agents"
  homepage "https://github.com/helixerio/memcp"
  url "https://github.com/helixerio/memcp/archive/refs/tags/v1.5.5.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "9b3f1290a7461128993a57e9b15349472b970159544f0857e66cc7432aa315c5"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/memcp-1.5.5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "55995559aef831207c20e764b2451722d3a84f81d63c04b4531462c828599dec"
    sha256 cellar: :any,                 arm64_linux:   "bc13f6bbbfbcb6f646c562d0a6f5ce5f90be9d19b251366a3b0946b0ec8f12f4"
    sha256 cellar: :any,                 x86_64_linux:  "5e8299ba5f1db25536735aa0536aad3ea6bd9d904e27d296dcecbc0f166167db"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  def install
    # Build the SvelteKit web dashboard
    system "npm", "install", "--prefix", "ui", *std_npm_args(prefix: false, ignore_scripts: false)
    system "npm", "run", "build", "--prefix", "ui"
    rm_r "internal/dashboard/static"
    mkdir_p "internal/dashboard/static"
    cp_r Dir["ui/build/*"], "internal/dashboard/static/"

    # Build the Go binary (embeds static/ via go:embed)
    ENV["CGO_ENABLED"] = "1"
    ENV["GOTOOLCHAIN"] = "auto"
    ldflags = "-s -w -X github.com/helixerio/memcp/cmd.currentVersion=#{version}"
    system "go", "build", *std_go_args(ldflags:)
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
