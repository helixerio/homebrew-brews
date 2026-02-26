class Memcp < Formula
  desc "Cross-session persistent memory MCP server for coding agents"
  homepage "https://github.com/helixerio/memcp"
  url "https://github.com/helixerio/memcp/archive/refs/tags/v1.3.1.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "51726d0491efcc7743afd62dcdb1796d2fad5223cf90f7b13645556afaa4de44"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/memcp-1.3.1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d857d0f918deb4ddc248fdaa3b5a9b4581ceb48be28eb82c76b9855e79fe7d95"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0bf9d0c3bb492d627d34c443fea95ea9e7f296a788b5738bce5039801d1c2bbe"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9e13e37f85c9f3666681f50737ca34b30d0fe52f020b7a7902eff0f59c437f52"
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
