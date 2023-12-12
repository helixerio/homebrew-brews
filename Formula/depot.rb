class Depot < Formula
  desc "Private Terraform Registry with support for Modules and Providers"
  homepage "https://github.com/helixerio/depot"
  url "https://github.com/helixerio/depot/archive/refs/tags/v0.3.1.tar.gz",
    header: "Authorization: token #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}"
  sha256 "4fe26ca0aa59cebaea45a2c12a0672b365ddd5bc149fa00241cdde2af27f48b9"

  bottle do
    root_url "https://github.com/helixerio/homebrew-brews/releases/download/depot-0.3.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e28cfc46e1aeaa0fdce90d1e7df51d45efedd6784d56ec26dd19722af24119bd"
    sha256 cellar: :any_skip_relocation, aarch64_linux: "e28cfc46e1aeaa0fdce90d1e7df51d45efedd6784d56ec26dd19722af24119bd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "13f2a00f315640c2670eae95f72217819c8edb06df809dcfc5c66fba2a9e3a48"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match "Depot version: 0.3.1", shell_output("#{bin}/depot version")
  end
end
