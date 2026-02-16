class Depot < Formula
  desc "Private Terraform Registry with support for Modules and Providers"
  homepage "https://github.com/helixerio/depot"
  url "https://github.com/helixerio/depot/archive/refs/tags/v0.5.0.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "de852c5f86d9eaec8664fda9e00be1e3f484dae4effca4600721b155d0bc2945"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/depot-0.5.0"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "029825e314cf68af3cb7effd1da966d1fdb021d18c9cec6635fc34350e76350a"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "3c92697dab73001da6888295230a4d2694f1e93db10ca8ca989699626e0d4222"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "730486b63ae77fb82ff990ca1f0b43b02ccaee7145f650412b3a359c5da613a1"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X github.com/helixerio/depot/cmd.currentVersion=#{version}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match "Depot version: #{version}", shell_output("#{bin}/depot version")
  end
end
