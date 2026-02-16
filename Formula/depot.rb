class Depot < Formula
  desc "Private Terraform Registry with support for Modules and Providers"
  homepage "https://github.com/helixerio/depot"
  url "https://github.com/helixerio/depot/archive/refs/tags/v0.5.0.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "de852c5f86d9eaec8664fda9e00be1e3f484dae4effca4600721b155d0bc2945"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/depot-0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4f1662f190b41813fabee8cb54acc660d4c67f98d9ca82bcef7ca6abef352992"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "87a1ef605d8740ab77e4358372de63084a1d1d9cc538de69659806dc2eec2ffb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "64e16450e695d520462c1176a06d0b1b8e83770dcf0181d2db4bde958a5c2dd6"
  end

  depends_on "go" => :build

  def install
    ENV["GOTOOLCHAIN"] = "auto"
    ldflags = "-s -w -X github.com/helixerio/depot/cmd.currentVersion=#{version}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match "Depot version: #{version}", shell_output("#{bin}/depot version")
  end
end
