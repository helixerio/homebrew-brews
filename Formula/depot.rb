class Depot < Formula
  desc "Private Terraform Registry with support for Modules and Providers"
  homepage "https://github.com/helixerio/depot"
  url "https://github.com/helixerio/depot/archive/v0.1.0.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "9bf3127433ecf37e11e2aef5c0aa8118c6dd59f79bedf0de25a6ed828367f721"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/depot-0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5239091543e32995e6799114c7740dd66e0b858f72d94ef1348d9c775a39f4d2"
    sha256 cellar: :any_skip_relocation, monterey:       "5aac48bd01cefacbc84ebae81bf3972589ff40f1728c7416aab8ef3cca80efd9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "2ae0217db41d7b6546c6df71b0b4861f42e15c495171e35e708a2b6297808913"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match "Depot version: 0.1.0", shell_output("#{bin}/depot version")
  end
end
