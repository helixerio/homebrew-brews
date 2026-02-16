class Depot < Formula
  desc "Private Terraform Registry with support for Modules and Providers"
  homepage "https://github.com/helixerio/depot"
  url "https://github.com/helixerio/depot/archive/refs/tags/v0.5.0.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "de852c5f86d9eaec8664fda9e00be1e3f484dae4effca4600721b155d0bc2945"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/depot-0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "51f0138e9411ecb379db5ed103745ca35062731c5dec2d83f9a0290e8c7bf8f8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "f232b9da754a0f88560238f80736f466d0334f048f32c18a63524d52d8c245a9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a79cd94e755e51e6adc5dc87c20e3b4b1f27e368893e2b7670f1304262387df2"
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
