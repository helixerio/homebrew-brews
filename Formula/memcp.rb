class Memcp < Formula
  desc "Cross-session persistent memory MCP server for coding agents"
  homepage "https://github.com/helixerio/memcp"
  url "https://github.com/helixerio/memcp/archive/refs/tags/v1.5.3.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "a8f740949f372f061c4de541cec192c473b9fb5b12a847b6275de4855ca5f1ab"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/memcp-1.5.3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3e8ecf451a73f6359b439cf3f004433a363b3a90e4619c275ab5cb33c4ad8a49"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fea06ea2236c08ad10bf6cb6841c12090a109fee5423703822c3db3547cfa0b6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "02424e286263a5439c4f29bddcadc0851390b46b883106a88a5795c13fd5411f"
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
