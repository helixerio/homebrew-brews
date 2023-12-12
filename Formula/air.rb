class Air < Formula
  desc "Live reload for Go apps"
  homepage "https://github.com/cosmtrek/air"
  url "https://github.com/cosmtrek/air/archive/refs/tags/v1.49.0.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "2e328445deb1a953b85a874f846ea6b73f2886f36a5dc0ef4261b69bcf05d6d2"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/air-1.40.4"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "2a7ebb1d95dc35da8770409eb7a2cfa30141230257534c2c7c0c83f200bb70a5"
    sha256 cellar: :any_skip_relocation, monterey:       "8b4a990cd6aef2252827e88bf93c449f78ff2c31293ad1a46b646ac575347d7d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c64aff833f84b6df93d3a97b128370a29be399e3b051f85f1192f89e2c66117c"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    shell_output("#{bin}/air -v")
  end
end
