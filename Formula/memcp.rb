class Memcp < Formula
  desc "Cross-session persistent memory MCP server for coding agents"
  homepage "https://github.com/helixerio/memcp"
  url "https://github.com/helixerio/memcp/archive/refs/tags/v1.2.0.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "a705181acc3bddf48eb887b19ae78bea398d12893abdeb257703e289606131a2"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/memcp-1.2.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fb34f1caeba4fbe6950a1a68d8e765fdbc65d98e7b2d1892acbf2df976db7d60"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "5bf38ba8e828674ee7e31d64df0c677edb2f3bf6f8f109b18de9d72e470bdd5a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "55edbbffcfb939d54d7e5fb8be1cd0b6964d812a19f7e4cfccb94592cbd2f5c8"
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
